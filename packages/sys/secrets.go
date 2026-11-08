package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// The admin key stays on its machine: sops reaches it through the sops key
// service, which the SSH connection forwards to this socket
func keyServiceSocket() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	socket := filepath.Join(home, ".sops-keyservice.sock")
	if info, err := os.Stat(socket); err != nil || info.Mode()&os.ModeSocket == 0 {
		return "", fmt.Errorf("no sops key service at %s: connect with it forwarded from the machine that holds your age key", socket)
	}
	return socket, nil
}

// sys secrets-sync writes the .sops.yaml that lib/sops-config generates to
// the nix-secrets checkout in secrets/, then re-encrypts the files whose
// readers changed
func secretsSync() error {
	checkout, err := filepath.Abs("secrets")
	if err != nil {
		return err
	}
	if _, err := os.Stat(filepath.Join(checkout, ".sops.yaml")); err != nil {
		return fmt.Errorf("run this in nix-config, with nix-secrets checked out in secrets/")
	}
	socket, err := keyServiceSocket()
	if err != nil {
		return err
	}

	// From the local checkouts, so that keys and files not committed yet count
	generate := func(output string) (string, error) {
		return runOutput("", "nix", "eval", "--impure", "--raw", "--expr", fmt.Sprintf(
			`let flake = builtins.getFlake "git+file://%s"; config = flake.lib.sopsConfig { hosts = flake.nixosConfigurations; secrets = %s; }; in %s`,
			filepath.Dir(checkout), checkout, output))
	}
	config, err := generate("config.yaml")
	if err != nil {
		return fmt.Errorf("generating .sops.yaml: %w", err)
	}
	if err := os.WriteFile(filepath.Join(checkout, ".sops.yaml"), []byte(config+"\n"), 0o644); err != nil {
		return err
	}
	log("Wrote secrets/.sops.yaml")

	output, err := generate("builtins.toJSON (map (rule: rule.file) config.rules)")
	if err != nil {
		return err
	}
	var files []string
	if err := json.Unmarshal([]byte(output), &files); err != nil {
		return err
	}

	// updatekeys leaves files that already match alone, without decrypting them
	for _, file := range files {
		if _, err := os.Stat(filepath.Join(checkout, file)); os.IsNotExist(err) {
			continue
		}
		cmd := exec.Command("sops", "updatekeys", "--keyservice", "unix://"+socket, "--yes", file)
		cmd.Dir = checkout
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("re-encrypting %s: %w", file, err)
		}
	}
	return nil
}

// sys secrets-push commits and pushes nix-secrets, then updates nix-config's
// secrets input and submodule to it, straight on main
func secretsPush() error {
	// The submodule is left out: its changes are the ones to push
	if status, err := runOutput("", "git", "status", "--porcelain", "--ignore-submodules=all"); err != nil || status != "" {
		return fmt.Errorf("nix-config has uncommitted changes: commit or stash them first")
	}
	if branch, err := runOutput("", "git", "symbolic-ref", "--short", "-q", "HEAD"); err != nil || branch != "main" {
		return fmt.Errorf("nix-config is not on main")
	}
	if _, err := runOutput("secrets", "git", "symbolic-ref", "-q", "HEAD"); err != nil {
		return fmt.Errorf("secrets/ is not on a branch: check one out so it can be pushed")
	}
	if err := runIn("", "git", "pull", "--ff-only"); err != nil {
		return err
	}

	if err := runIn("secrets", "git", "add", "-A"); err != nil {
		return err
	}
	if staged, err := runOutput("secrets", "git", "diff", "--cached", "--name-status"); err != nil {
		return err
	} else if staged == "" {
		log("Nothing to commit in nix-secrets")
	} else {
		fmt.Println(staged)
		fmt.Print(":: Commit message for nix-secrets (empty to stop): ")
		message, _ := stdin.ReadString('\n')
		message = strings.TrimSpace(message)
		if message == "" {
			return fmt.Errorf("no commit message: the changes are staged in secrets/, nothing was committed")
		}
		if err := runIn("secrets", "git", "commit", "-m", message); err != nil {
			return err
		}
	}
	if err := runIn("secrets", "git", "push"); err != nil {
		return err
	}

	if err := runIn("", "nix", "flake", "update", "secrets"); err != nil {
		return err
	}
	if err := runIn("", "git", "add", "flake.lock", "secrets"); err != nil {
		return err
	}
	if changed, err := runOutput("", "git", "diff", "--cached", "--name-only"); err != nil {
		return err
	} else if changed == "" {
		log("nix-config already points at these secrets")
		return nil
	}
	if err := runIn("", "git", "commit", "-m", "Update secrets"); err != nil {
		return err
	}
	return runIn("", "git", "push", "origin", "HEAD:refs/heads/main")
}

func runOutput(dir, name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stderr = os.Stderr
	output, err := cmd.Output()
	return strings.TrimSpace(string(output)), err
}
