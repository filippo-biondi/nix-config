{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim.url = "github:filippo-biondi/nvim-config";
    # nvim.url = "path:/home/filippo/nvim-config";

    connecttunnel-nix.url = "github:iannisimo/connecttunnel-nix";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          overlays = [ inputs.nvim.overlays.default ];
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay-unstable ];
      };
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
              nixpkgs.config.allowUnfree = true;
            })
            inputs.connecttunnel-nix.nixosModule
            ./configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.filippo = import ./home.nix;
            }
          ];
        };
      };

    homeConfigurations = {
        fbiondi = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          # Here, ./home.nix is your home-manager configuration.
          modules = [ ./home.nix ];
        };
      };
  };
}
