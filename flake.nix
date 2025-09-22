{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-nightly.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-24.05";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv";

    nvim.url = "github:filippo-biondi/nvim-config";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    connecttunnel-nix.url = "github:iannisimo/connecttunnel-nix";

    interpelli-bot.url = "git+ssh://git@github.com/filippo-biondi/interpelli-bot.git";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) outputs;
      utils = import ./utils { inherit nixpkgs self inputs outputs; };

    in with utils; {
      nixosConfigurations = with nixos; {
        msi = mkConfiguration {
          system = "x86_64-linux";
          hostname = "msi";
          username = "filippo";
          extraModules = [
            inputs.interpelli-bot.nixosModules."${system}".default
          ];
        };
        server-stella = mkConfiguration { system="x86_64-linux"; hostname="server-stella"; username="filippo"; };
        server-casa = mkConfiguration { system="aarch64-linux"; hostname="server-casa"; username="filippo"; };
      };

      darwinConfigurations = with darwin; {
        "macbook-pro" = mkConfiguration { system="aarch64-darwin"; hostname="macbook-pro"; username="filippo"; };
      };

      homeConfigurations = with home; {
        "fbiondi@giova-sssa" = mkConfiguration { system="x86_64-linux"; hostname="giova-sssa"; username="fbiondi"; };
      };

      overlays = import ./overlays { inherit inputs; };

      templates = import ./templates {};
    };
}
