package main

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"golang.org/x/crypto/ssh"
)

// The installer is a new machine each time it boots, with a new host key
var installerSSH = []string{"-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "-o", "LogLevel=ERROR"}

// sys add-host sets up a machine booted from the installer as one of the
// flake's hosts: it gives the host an SSH key, adds the host to nix-secrets
// and its secrets, deploys it, and commits the result in both repositories
func addHost(host, address, user string) error {
	for _, dir := range []string{".", "secrets"} {
		if status, err := runOutput(dir, "git", "status", "--porcelain"); err != nil || status != "" {
			return fmt.Errorf("%s has uncommitted changes: commit them, then run add-host again", dir)
		}
	}
	if _, err := runOutput("secrets", "git", "symbolic-ref", "-q", "HEAD"); err != nil {
		return fmt.Errorf("secrets/ is not on a branch: check one out so add-host can push")
	}
	socket, err := keyServiceSocket()
	if err != nil {
		return err
	}

	// What add-host needs from the host's configuration
	output, err := runOutput("", "nix", "eval", "--json", ".#nixosConfigurations."+host+".config", "--apply", `config: {
		arch = config.nixpkgs.system;
		sd = config.system.build ? sdImage;
		secrets = map (secret: secret.key)
			(builtins.filter (secret: builtins.match ".*/secrets/`+host+`/secrets.yaml" (toString secret.sopsFile) != null)
			(builtins.attrValues config.sops.secrets));
		sharedSecrets = builtins.concatMap (secret: let
			file = builtins.match ".*/(secrets/[^/]+[.]yaml)" (toString secret.sopsFile);
		in
			if file == null then [] else [{file = builtins.head file; inherit (secret) key;}])
			(builtins.attrValues config.sops.secrets);
	}`)
	if err != nil {
		return fmt.Errorf("reading the configuration of %s: %w", host, err)
	}
	var config struct {
		Arch          string
		SD            bool
		Secrets       []string
		SharedSecrets []struct{ File, Key string }
	}
	if err := json.Unmarshal([]byte(output), &config); err != nil {
		return err
	}
	if !config.SD {
		return fmt.Errorf("%s has no SD card layout: only SD card hosts are supported for now", host)
	}

	// The shared secrets the host reads must already exist: otherwise the deploy
	// would fail on them, after nix-secrets has been pushed
	var missing []string
	for _, secret := range config.SharedSecrets {
		path := ""
		for _, part := range strings.Split(secret.Key, "/") {
			path += fmt.Sprintf("[%q]", part)
		}
		find := exec.Command("sops", "--keyservice", "unix://"+socket, "--decrypt", "--extract", path, secret.File)
		find.Dir = "secrets"
		if find.Run() != nil {
			missing = append(missing, secret.Key+" in "+secret.File)
		}
	}
	if len(missing) > 0 {
		return fmt.Errorf("%s reads secrets that don't exist yet: %s. Add them, then run add-host again", host, strings.Join(missing, ", "))
	}

	target := user + "@" + address
	running, err := runOutput("", "ssh", append(installerSSH, target, "cat /etc/hostname")...)
	if err != nil {
		return fmt.Errorf("connecting to %s: %w", target, err)
	}
	if running != "installer-"+config.Arch {
		return fmt.Errorf("%s runs %s, not installer-%s: refusing to replace it", address, running, config.Arch)
	}

	// The host key stored in nix-secrets keeps a reinstalled host's identity.
	// It only ever exists in plain text in memory and on the host
	storedKey := filepath.Join("secrets", host, "ssh-host-key.yaml")
	_, err = os.Stat(filepath.Join("secrets", storedKey))
	newKey := os.IsNotExist(err)
	var privateKey string
	if newKey {
		log("Generating a host key...")
		_, private, err := ed25519.GenerateKey(rand.Reader)
		if err != nil {
			return err
		}
		block, err := ssh.MarshalPrivateKey(private, "root@"+host)
		if err != nil {
			return err
		}
		privateKey = string(pem.EncodeToMemory(block))
	} else {
		log("Decrypting the stored host key...")
		privateKey, err = runOutput("secrets", "sops", "--keyservice", "unix://"+socket,
			"--decrypt", "--extract", `["ssh_host_ed25519_key"]`, storedKey)
		if err != nil {
			return err
		}
		privateKey += "\n"
	}
	signer, err := ssh.ParsePrivateKey([]byte(privateKey))
	if err != nil {
		return err
	}
	publicKey := strings.TrimSpace(string(ssh.MarshalAuthorizedKey(signer.PublicKey()))) + " root@" + host
	ageKey, err := runInput(publicKey, "", "ssh-to-age")
	if err != nil {
		return err
	}
	if err := os.WriteFile(filepath.Join("secrets", "keys", host), []byte(ageKey+"\n"), 0o644); err != nil {
		return err
	}

	// The host now has rules in .sops.yaml, and the shared files it reads
	// are re-encrypted for it
	if err := secretsSync(); err != nil {
		return err
	}

	if newKey {
		if err := encrypt(storedKey, map[string]any{"ssh_host_ed25519_key": privateKey}); err != nil {
			return err
		}
	}

	ownFile := filepath.Join("secrets", host, "secrets.yaml")
	if len(config.Secrets) > 0 {
		if _, err := os.Stat(filepath.Join("secrets", ownFile)); err == nil &&
			!confirm(fmt.Sprintf("%s exists. Replace it with new values for %s?", ownFile, strings.Join(config.Secrets, ", "))) {
			return fmt.Errorf("keeping %s: re-encrypt it for %s with sys secrets-sync instead", ownFile, host)
		}
		// sops-nix reads filippo/passwordHash from {filippo: {passwordHash: ...}}
		secrets := map[string]any{}
		for _, key := range config.Secrets {
			value, err := askSecret(key)
			if err != nil {
				return err
			}
			parts := strings.Split(key, "/")
			parent := secrets
			for _, part := range parts[:len(parts)-1] {
				if _, ok := parent[part].(map[string]any); !ok {
					parent[part] = map[string]any{}
				}
				parent = parent[part].(map[string]any)
			}
			parent[parts[len(parts)-1]] = value
		}
		if err := encrypt(ownFile, secrets); err != nil {
			return err
		}
	}

	log("Committing and pushing nix-secrets...")
	for _, args := range [][]string{{"add", "-A"}, {"commit", "-m", "Add " + host}, {"push"}} {
		if err := runIn("secrets", "git", args...); err != nil {
			return err
		}
	}
	if err := runIn(".", "nix", "flake", "update", "secrets"); err != nil {
		return err
	}

	log(fmt.Sprintf("Copying the host key to %s...", address))
	install := "sudo install -D -m %s /dev/stdin /etc/ssh/ssh_host_ed25519_key%s"
	if _, err := runInput(privateKey, "", "ssh", append(installerSSH, target, fmt.Sprintf(install, "600", ""))...); err != nil {
		return err
	}
	if _, err := runInput(publicKey+"\n", "", "ssh", append(installerSSH, target, fmt.Sprintf(install, "644", ".pub"))...); err != nil {
		return err
	}

	// boot rather than switch: the machine keeps running the installer, with its
	// passwordless sudo and its hostname, until it reboots into its configuration
	log(fmt.Sprintf("Deploying %s to %s...", host, address))
	deploy := exec.Command("nixos-rebuild", "boot", "--flake", ".#"+host,
		"--target-host", target, "--sudo", "--use-substitutes")
	deploy.Env = append(os.Environ(), "NIX_SSHOPTS="+strings.Join(installerSSH, " "))
	deploy.Stdin, deploy.Stdout, deploy.Stderr = os.Stdin, os.Stdout, os.Stderr
	if err := deploy.Run(); err != nil {
		return err
	}

	if err := runIn(".", "git", "add", "flake.lock", "secrets"); err != nil {
		return err
	}
	if err := runIn(".", "git", "commit", "-m", "Set up "+host); err != nil {
		return err
	}
	// The connection drops as the machine goes down, so its status says nothing
	log(fmt.Sprintf("Rebooting %s into its configuration...", host))
	reboot := exec.Command("ssh", append(installerSSH, target, "sudo systemctl reboot")...)
	reboot.Stdin, reboot.Stdout, reboot.Stderr = os.Stdin, os.Stdout, os.Stderr
	reboot.Run()

	log(fmt.Sprintf("%s is set up and rebooting. Upload the nix-config commit for review.", host))
	return nil
}

// Asks for a secret: a password twice, stored as its hash, or a pasted value
func askSecret(key string) (string, error) {
	if !strings.HasSuffix(key, "passwordHash") {
		return readHidden(fmt.Sprintf("Value of %s: ", key))
	}
	password, err := readHidden(fmt.Sprintf("Password for %s: ", strings.TrimSuffix(key, "/passwordHash")))
	if err != nil {
		return "", err
	}
	if again, err := readHidden("Again: "); err != nil || again != password {
		return "", fmt.Errorf("the passwords differ")
	}
	return runInput(password, "", "mkpasswd", "--method=yescrypt", "--stdin")
}

func readHidden(prompt string) (string, error) {
	fmt.Print(":: " + prompt)
	stty := func(arg string) {
		cmd := exec.Command("stty", arg)
		cmd.Stdin = os.Stdin
		cmd.Run()
	}
	stty("-echo")
	defer stty("echo")
	line, err := stdin.ReadString('\n')
	fmt.Println()
	return strings.TrimSpace(line), err
}

// Encrypts secrets into a file of nix-secrets, for the readers its rule
// names. sops reads them from standard input, so the plain text never
// touches the disk, and encrypting needs no key
func encrypt(file string, secrets map[string]any) error {
	plain, err := json.Marshal(secrets)
	if err != nil {
		return err
	}
	encrypted, err := runInput(string(plain), "secrets", "sops", "--encrypt",
		"--input-type", "json", "--output-type", "yaml", "--filename-override", file, "/dev/stdin")
	if err != nil {
		return err
	}
	path := filepath.Join("secrets", file)
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, []byte(encrypted+"\n"), 0o644)
}

func runInput(input, dir, name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdin = strings.NewReader(input)
	cmd.Stderr = os.Stderr
	output, err := cmd.Output()
	return strings.TrimSpace(string(output)), err
}

func runIn(dir, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
	log(fmt.Sprintf("Running: %s %s", name, strings.Join(args, " ")))
	return cmd.Run()
}
