package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
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
		Short: "A command-line utility for managing NixOS, nix-darwin and Home Manager configurations.",
	}

	var rebuildCmd = &cobra.Command{
		Use:     "rebuild",
		Aliases: []string{"r"},
		Short:   "Rebuild the system (auto-detects OS).",
		Run: func(cmd *cobra.Command, args []string) {
			switch runtime.GOOS {
			case "linux":
				log("Rebuilding NixOS configuration...")
				if err := runSudoCmd("nixos-rebuild", "switch", "--flake", ".#"); err != nil {
					fmt.Printf("Error rebuilding NixOS: %v\n", err)
					os.Exit(1)
				}
			case "darwin":
				log("Rebuilding Darwin configuration...")
				if err := runSudoCmd("darwin-rebuild", "switch", "--flake", ".#"); err != nil {
					fmt.Printf("Error rebuilding Darwin: %v\n", err)
					os.Exit(1)
				}
			default:
				fmt.Printf("❌ Unsupported OS: %s\n", runtime.GOOS)
				os.Exit(1)
			}
		},
	}

	rootCmd.AddCommand(rebuildCmd)

	var testCmd = &cobra.Command{
		Use:     "test",
		Aliases: []string{"t"},
		Short:   "Test configuration (NixOS test / Darwin check).",
		Run: func(cmd *cobra.Command, args []string) {
			switch runtime.GOOS {
			case "linux":
				log("Testing NixOS configuration...")
				if err := runSudoCmd("nixos-rebuild", "test", "--flake", ".#"); err != nil {
					fmt.Printf("Error testing NixOS: %v\n", err)
					os.Exit(1)
				}
			case "darwin":
				log("Checking Darwin configuration...")
				if err := runCmd("darwin-rebuild", "check", "--flake", ".#"); err != nil {
					fmt.Printf("Error checking Darwin: %v\n", err)
					os.Exit(1)
				}
			default:
				fmt.Printf("❌ Unsupported OS: %s\n", runtime.GOOS)
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

			target := fmt.Sprintf("%s@%s", user, host)
			log(fmt.Sprintf("Deploying flake .#%s to %s...", host, target))

			if err := runSudoCmd("nixos-rebuild", "switch",
				"--flake", fmt.Sprintf(".#%s", host),
				"--target-host", target,
				"--use-remote-sudo",
				"--ask-sudo-password",
			); err != nil {
				fmt.Printf("Error deploying to %s: %v\n", target, err)
				os.Exit(1)
			}
		},
	}
	rootCmd.AddCommand(deployCmd)

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
