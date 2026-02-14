# Nix Configuration

This repository contains the Nix configuration for my personal infrastructure, managed using [Flakes](https://nixos.wiki/wiki/Flakes) and structured with [Snowfall Lib](https://github.com/snowfallorg/lib).

It manages **NixOS**, **macOS (Darwin)**, and standalone **Home Manager** configurations.

## Prerequisites

The only prerequisite is **[Nix](https://nixos.org/download.html)** with Flakes enabled.

All other tools (secrets management, custom scripts, git hooks) are provided via the development shell.

## Usage

### 1. Enter the Environment

Enter the development shell to access all necessary tools (`sys`, `sops`, `age`, `git`):

```bash
nix develop
```

This will also automatically install the **pre-commit hooks** (using `treefmt`) to ensure code is formatted before every commit.

### 2. The `sys` Command

This configuration includes a custom wrapper script named `sys` to simplify common tasks.

```bash
# Rebuild the system (auto-detects OS)
sys rebuild

# Update flake inputs
sys update

# Garbage collect and optimise Nix Store
sys clean

# Deploy to a remote NixOS host
sys deploy <hostname> [user]

# Bootstrap a new host (keys, secrets, provisioning)
sys add-host
```

### 3. Applying Configuration Manually

If you prefer standard commands:

**macOS (Darwin):**
```bash
darwin-rebuild switch --flake .#
```

**NixOS:**
```bash
sudo nixos-rebuild switch --flake .#
```

**Home Manager (Standalone):**
```bash
home-manager switch --flake .
```

## Secrets

Secrets are managed using **sops-nix** and **age**. The encrypted files are located in the `secrets/` submodule (private repository).

To manage secrets, ensure you are in the `nix develop` shell.

See [secrets/README.md](./secrets/README.md) for detailed management instructions.

## Credits

*   [Snowfall Lib](https://github.com/snowfallorg/lib)
*   [snowfall-starter](https://github.com/IogaMaster/snowfall-starter)
*   [usmcamp0811's dotfiles](https://gitlab.com/usmcamp0811/dotfiles/-/tree/nixos)