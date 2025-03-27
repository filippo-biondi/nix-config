{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    nvim.url = "github:filippo-biondi/nvim-config";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    connecttunnel-nix.url = "github:iannisimo/connecttunnel-nix";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      inherit (self) outputs;

      get_user = name:
        let users = rec {
          filippo = {
            fullName = "Filippo Biondi";
            email = "filibiondi2000@gmail.com";
            inherit name;
          };
          fbiondi = filippo // {
            email = "filippo.biondi@santanna.it";
          };
        };
        in users.${name};

      mkNixosConfiguration = system: hostname: username:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = get_user username;
            nixosModules = "${self}/modules/nixos";
          };
          modules = [
            ./hosts/${hostname}
            inputs.connecttunnel-nix.nixosModule
            ];
        };

      mkDarwinConfiguration = hostname: username:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = get_user username;
          };
          modules = [
            ./hosts/${hostname}
            home-manager.darwinModules.home-manager
            inputs.nix-homebrew.darwinModules.nix-homebrew
          ];
        };

      mkHomeConfiguration = system: hostname: username:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        extraSpecialArgs = {
          inherit inputs outputs;
          userConfig = get_user username;
          nhModules = "${self}/modules/home-manager";
        };
        modules = [
          ./home/${hostname}/${username}
        ];
      };
    in {
      nixosConfigurations = {
        msi = mkNixosConfiguration "x86_64-linux" "msi" "filippo";
      };

      darwinConfigurations = {
        "macbook-pro" = mkDarwinConfiguration "macbook-pro" "filippo";
      };


      homeConfigurations = {
        "filippo@msi" = mkHomeConfiguration "x86_64-linux" "msi" "filippo";
        "filippo@macbook-pro" = mkHomeConfiguration "aarch64-darwin" "macbook-pro" "filippo";
        "fbiondi@giova-sssa" = mkHomeConfiguration "x86_64-linux" "giova-sssa" "fbiondi";
      };
      overlays = import ./overlays { inherit inputs; };
    };
}
