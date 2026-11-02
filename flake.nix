{
  description = "Multi-host multi-system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-nightly.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim.url = "github:filippo-biondi/nvim-config";

    interpelli-bot.url = "git+ssh://git@github.com/filippo-biondi/interpelli-bot.git";

    proxmox-nixos.url = "github:greg-hellings/proxmox-nixos/fix/212-AcceptEnv-redefinition";

    secrets.url = "git+ssh://git@github.com/filippo-biondi/nix-secrets.git";

    claude-plugins = {
      url = "git+ssh://git@github.com/filippo-biondi/claude-plugins.git";
      flake = false;
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;

      snowfall = {
        meta = {
          name = "dotfiles";
          title = "dotfiles";
        };

        namespace = "ccg";
      };
    };
  in
    lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
      };

      overlays = with inputs; [
        nvim.overlays.default
      ];

      systems.modules.nixos = with inputs; [
        ./modules/shared
        ./modules/usersCatalog
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        proxmox-nixos.nixosModules.proxmox-ve
        interpelli-bot.nixosModules.default
      ];
      homes.modules = [
        ./modules/usersCatalog
      ];

      outputs-builder = channels: let
        pkgs = channels.nixpkgs;
      in {
        formatter = pkgs.treefmt-configured.wrapper;

        # Every NixOS host of this system, to build them all with one command
        packages.nixos-hosts = pkgs.linkFarm "nixos-hosts" (
          lib.mapAttrs (_: host: host.config.system.build.toplevel)
          (lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == pkgs.stdenv.hostPlatform.system)
            inputs.self.nixosConfigurations)
        );

        checks = {
          # formatting = pkgs.treefmt-configured.check inputs.self;
          pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
            src = ./.;
            hooks = {
              treefmt = {
                enable = true;
                package = pkgs.treefmt-configured.wrapper;
              };
            };
          };
        };
      };
    };
}
