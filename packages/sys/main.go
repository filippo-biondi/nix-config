package main

import (
	"bufio"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/spf13/cobra"
)

// Helper functions
func log(message string) {
	fmt.Printf(":: %s\n", message)
}

func warn(message string) {
	fmt.Printf(":: %s\n", message)
}

func confirm(prompt string) bool {
	reader := bufio.NewReader(os.Stdin)
	for {
		fmt.Printf(":: %s (y/n): ", prompt)
		input, _ := reader.ReadString('\n')
		input = strings.ToLower(strings.TrimSpace(input))
		if input == "y" || input == "yes" {
			return true
		} else if input == "n" || input == "no" {
			return false
		} else {
			fmt.Println("Please answer 'y' or 'n'.")
		}
	}
}

func runCmd(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	log(fmt.Sprintf("Running: %s %s", name, strings.Join(args, " ")))
	return cmd.Run()
}

func runSudoCmd(name string, args ...string) error {
	sudoArgs := append([]string{name}, args...)
	cmd := exec.Command("sudo", sudoArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	log(fmt.Sprintf("Running: sudo %s %s", name, strings.Join(args, " ")))
	return cmd.Run()
}

func main() {
	var rootCmd = &cobra.Command{
		Use:   "sys",
		Short: "A command-line utility for managing NixOS and Home Manager configurations.",
	}

	var rebuildCmd = &cobra.Command{
		Use:     "rebuild",
		Aliases: []string{"r"},
		Short:   "Rebuild the system.",
		Run: func(cmd *cobra.Command, args []string) {
			log("Rebuilding NixOS configuration...")
			if err := runSudoCmd("nixos-rebuild", "switch", "--flake", ".#"); err != nil {
				fmt.Printf("Error rebuilding NixOS: %v\n", err)
				os.Exit(1)
			}
		},
	}

	rootCmd.AddCommand(rebuildCmd)

	var testCmd = &cobra.Command{
		Use:     "test",
		Aliases: []string{"t"},
		Short:   "Test configuration.",
		Run: func(cmd *cobra.Command, args []string) {
			log("Testing NixOS configuration...")
			if err := runSudoCmd("nixos-rebuild", "test", "--flake", ".#"); err != nil {
				fmt.Printf("Error testing NixOS: %v\n", err)
				os.Exit(1)
			}
		},
	}
	rootCmd.AddCommand(testCmd)

	var homeSwitchCmd = &cobra.Command{
		Use:     "home-switch",
		Aliases: []string{"hs"},
		Short:   "Switch Home Manager configuration.",
		Run: func(cmd *cobra.Command, args []string) {
			log("Switching Home Manager configuration...")
			if err := runCmd("home-manager", "switch", "--flake", ".#"); err != nil {
				fmt.Printf("Error switching Home Manager: %v\n", err)
				os.Exit(1)
			}
		},
	}
	rootCmd.AddCommand(homeSwitchCmd)

	var homeTestCmd = &cobra.Command{
		Use:     "home-test",
		Aliases: []string{"ht"},
		Short:   "Test Home Manager configuration.",
		Run: func(cmd *cobra.Command, args []string) {
			log("Testing Home Manager configuration...")
			if err := runCmd("home-manager", "test", "--flake", ".#"); err != nil {
				fmt.Printf("Error testing Home Manager: %v\n", err)
				os.Exit(1)
			}
		},
	}
	rootCmd.AddCommand(homeTestCmd)

	var updateCmd = &cobra.Command{
		Use:     "update",
		Aliases: []string{"u"},
		Short:   "Update flake inputs.",
		Run: func(cmd *cobra.Command, args []string) {
			log("Updating flake.lock...")
			if err := runCmd("nix", "flake", "update"); err != nil {
				fmt.Printf("Error updating flake: %v\n", err)
				os.Exit(1)
			}
		},
	}
	rootCmd.AddCommand(updateCmd)

	var cleanCmd = &cobra.Command{
		Use:     "clean",
		Aliases: []string{"c"},
		Short:   "Garbage collect and optimise Nix Store.",
		Run: func(cmd *cobra.Command, args []string) {
			log("Cleaning and optimizing the Nix store...")
			if err := runCmd("nix", "store", "optimise", "--verbose"); err != nil {
				fmt.Printf("Error optimizing Nix store: %v\n", err)
				os.Exit(1)
			}
			if err := runCmd("nix", "store", "gc", "--verbose"); err != nil {
				fmt.Printf("Error cleaning Nix store: %v\n", err)
				os.Exit(1)
			}
		},
	}
	rootCmd.AddCommand(cleanCmd)

	var deployCmd = &cobra.Command{
		Use:     "deploy <host> [user]",
		Aliases: []string{"d"},
		Short:   "Deploy to a remote NixOS host.",
		Args:    cobra.RangeArgs(1, 2), // Requires 1 or 2 arguments
		Run: func(cmd *cobra.Command, args []string) {
			host := args[0]
			user := "filippo" // Default user
			if len(args) > 1 {
				user = args[1]
			}

			// --to reaches a host under another address, such as a new machine's IP
			address, _ := cmd.Flags().GetString("to")
			if address == "" {
				address = host
			}
			target := fmt.Sprintf("%s@%s", user, address)
			log(fmt.Sprintf("Deploying flake .#%s to %s...", host, target))

			// Runs as the user, so SSH uses their keys and agent: only the target needs root
			if err := runCmd("nixos-rebuild", "switch",
				"--flake", fmt.Sprintf(".#%s", host),
				"--target-host", target,
				"--sudo",
				"--ask-elevate-password",
				// The target downloads what the binary cache has instead of receiving it from here
				"--use-substitutes",
			); err != nil {
				fmt.Printf("Error deploying to %s: %v\n", target, err)
				os.Exit(1)
			}
		},
	}
	deployCmd.Flags().String("to", "", "address to deploy to instead of the host name")
	rootCmd.AddCommand(deployCmd)

	var imageCmd = &cobra.Command{
		Use:     "image <host> [variant] [arch]",
		Aliases: []string{"i"},
		Short:   "Build an image of a host, such as an ISO or an SD card, into images/.",
		Long: `Build one of NixOS's image variants of a host (iso, sd-card, qemu, ...)
into images/<host>-<variant>-<arch>. The variant defaults to iso and the
architecture to this machine's. A host with one configuration per
architecture, like installer-x86_64-linux and installer-aarch64-linux,
is named without the suffix: sys image installer sd-card aarch64-linux.`,
		Args: cobra.RangeArgs(1, 3),
		Run: func(cmd *cobra.Command, args []string) {
			host := args[0]
			variant := "iso"
			if len(args) > 1 {
				variant = args[1]
			}
			arch := map[string]string{"amd64": "x86_64-linux", "arm64": "aarch64-linux"}[runtime.GOARCH]
			if len(args) > 2 {
				arch = args[2]
			}

			// The installer exists once per architecture, as installer-<arch>
			config := host
			if output, err := exec.Command("nix", "eval", ".#nixosConfigurations",
				"--apply", fmt.Sprintf(`configs: configs ? "%s-%s"`, host, arch),
			).Output(); err == nil && strings.TrimSpace(string(output)) == "true" {
				config = host + "-" + arch
			}

			// The link keeps the image from being garbage collected until it is removed
			link := filepath.Join("images", fmt.Sprintf("%s-%s-%s", host, variant, arch))
			if err := os.MkdirAll("images", 0o755); err != nil {
				fmt.Printf("Error creating images: %v\n", err)
				os.Exit(1)
			}
			image := fmt.Sprintf(".#nixosConfigurations.%s.config.system.build.images.%s", config, variant)
			if err := runCmd("nix", "build", image, "--out-link", link); err != nil {
				fmt.Printf("Error building the %s image of %s: %v\n", variant, host, err)
				os.Exit(1)
			}

			// Each variant puts its file somewhere else in the output
			filepath.WalkDir(link+"/", func(path string, entry fs.DirEntry, err error) error {
				if err == nil && entry.IsDir() && entry.Name() == "nix-support" {
					return filepath.SkipDir
				}
				if err == nil && !entry.IsDir() {
					log(fmt.Sprintf("Image: %s", path))
				}
				return nil
			})
		},
	}
	rootCmd.AddCommand(imageCmd)

	var addHostCmd = &cobra.Command{
		Use:   "add-host [host_name] [target_host]",
		Short: "Interactive script to bootstrap a new host (placeholder).",
		Args:  cobra.MaximumNArgs(2), // Allows 0, 1, or 2 arguments
		Run: func(cmd *cobra.Command, args []string) {
			warn("The 'add-host' command is complex and currently a placeholder.")
			hostName := "N/A"
			targetHost := "N/A"

			if len(args) > 0 {
				hostName = args[0]
			}
			if len(args) > 1 {
				targetHost = args[1]
			}
			fmt.Printf("  HOST_NAME: %s, TARGET_HOST: %s\n", hostName, targetHost)
			os.Exit(1)
		},
	}
	rootCmd.AddCommand(addHostCmd)

	// cobra.Command has a default 'completion' command built-in.
	// We don't need to write it, but we do need to execute the root.
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
