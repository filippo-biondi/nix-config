# Nix Configuration

This repository contains the Nix configuration for my personal infrastructure, managed using [Flakes](https://nixos.wiki/wiki/Flakes) and structured with [Snowfall Lib](https://github.com/snowfallorg/lib).

It manages **NixOS** and standalone **Home Manager** configurations.

## Hosts

| Host | System | Notes |
| --- | --- | --- |
| `server-msi` | NixOS | Main server, with an NVIDIA GPU; runs most self-hosted services |
| `server-stella` | NixOS | Smaller server (BIOS boot) |
| `installer` | NixOS | Minimal system for bootstrapping a new machine: root SSH login with my key, passwordless sudo |

## Layout

Snowfall Lib builds the flake outputs from the directory tree, so a new host, home or module is picked up without being listed anywhere.

```
systems/<arch>/<host>/         one directory per machine (default.nix, hardware-configuration.nix)
homes/<arch>/<user>@<host>/    Home Manager configuration per user and machine
homes/filippo/                 my home configuration, imported by every filippo@<host>
modules/nixos/                 NixOS modules
modules/home/                  Home Manager modules
modules/shared/                modules for every system (Nix settings, fonts)
modules/usersCatalog/          the users of each host
lib/                           helpers available as lib.ccg.*
overlays/                      pkgs.stable (nixos-25.05), pkgs.nightly, the treefmt wrapper
packages/sys/                  the sys command
shells/default/                the development shell
secrets/                       encrypted secrets (submodule, private repository)
```

## How it fits together

Every module is off by default. It declares an option under the `ccg` namespace, usually mirroring its path, and keeps its configuration behind it:

```nix
options.ccg.networking.tailscale.enable = lib.ccg.mkBoolOpt' false;
config = lib.mkIf cfg.enable { ... };
```

A host's `default.nix` is then mostly a list of switches, such as `ccg.docker.enable = true;`, next to what only that machine has: hardware, disks and its `stateVersion`.

Users are defined once, in `modules/usersCatalog`, grouped by host. A host picks up its own with `ccg.users = config.ccg.usersCatalog.${host};`, and those with `setPassword = true` read their password hash from the host's secrets.

## Usage

The only prerequisite is **[Nix](https://nixos.org/download.html)** with Flakes enabled.

### 1. Enter the Environment

The development shell provides `sys`, `sops`, `age`, `ssh-to-age` and `git`:

```bash
nix develop
```

It also installs a **pre-commit hook** that checks formatting with `treefmt` (alejandra, statix, deadnix, shfmt). `nix fmt` formats the whole tree.

### 2. The `sys` Command

`sys` wraps the common tasks:

```bash
sys rebuild              # switch this machine to the configuration
sys test                 # activate without making it the boot default
sys home-switch          # switch the standalone Home Manager configuration
sys home-test            # test it without switching
sys update               # update all flake inputs
sys clean                # optimise and garbage collect the Nix store
sys deploy <host> [user] # build here and switch a remote NixOS host over SSH (user defaults to filippo)
```

`sys add-host` is a placeholder and does nothing yet.

### 3. Without `sys`

```bash
sudo nixos-rebuild switch --flake .   # NixOS
home-manager switch --flake .         # Home Manager
```

## Secrets

Secrets are managed with **sops-nix** and **age**. They live in a separate private repository, which this one uses twice: as the flake input `secrets`, which builds read, and as the `secrets/` submodule, where they are edited. Builds use the revision pinned in `flake.lock`, so a change to the secrets takes effect once that input is updated.

See [secrets/README.md](./secrets/README.md) for how the secrets and their keys are organised.

## Credits

*   [Snowfall Lib](https://github.com/snowfallorg/lib)
*   [snowfall-starter](https://github.com/IogaMaster/snowfall-starter)
*   [usmcamp0811's dotfiles](https://gitlab.com/usmcamp0811/dotfiles/-/tree/nixos)
