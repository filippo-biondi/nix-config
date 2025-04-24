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

    sops-nix.url = "github:Mic92/sops-nix";

    nvim.url = "github:filippo-biondi/nvim-config";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    connecttunnel-nix.url = "github:iannisimo/connecttunnel-nix";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      inherit (self) outputs;

      get_users = hostname:
        let config = import ./hosts {};
        in nixpkgs.lib.mapAttrs (name: value: value // { username = name; }) config.${hostname};

      home-manager-args = system: hostname: username: userConfig: {
        home-manager.extraSpecialArgs = {
          inherit inputs outputs system userConfig;
          hmModules = "${self}/modules/home-manager";
        };
        home-manager.users.${username} = import ./hosts/${hostname}/home/${username};
      };

      mkNixosConfiguration = system: hostname: username:
        let
          users = get_users hostname;
          userConfig = users.${username};
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs hostname users userConfig;
            nixosModules = "${self}/modules/nixos";
          };
          modules = [
            ./hosts/${hostname}
            inputs.connecttunnel-nix.nixosModule
            home-manager.nixosModules.home-manager (home-manager-args system hostname username userConfig)
          ];
        };

      mkDarwinConfiguration = system: hostname: username:
        let
          users = get_users hostname;
          userConfig = users.${username};
        in nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs hostname users userConfig;
            darwinModules = "${self}/modules/darwin";
          };
          modules = [
            ./hosts/${hostname}
            inputs.nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager (home-manager-args system hostname username userConfig)
          ];
        };

      mkHomeConfiguration = system: hostname: username:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        extraSpecialArgs = {
          inherit inputs outputs system;
          userConfig = (get_users hostname).${username};
          hmModules = "${self}/modules/home-manager";
        };
        modules = [
          ./home/${hostname}/${username}
        ];
      };
    in {
      nixosConfigurations = {
        msi = mkNixosConfiguration "x86_64-linux" "msi" "filippo";
        server-stella = mkNixosConfiguration "x86_64-linux" "server-stella" "filippo";
      };

      darwinConfigurations = {
        "macbook-pro" = mkDarwinConfiguration "aarch64-darwin" "macbook-pro" "filippo";
      };

      homeConfigurations = {
        "fbiondi@giova-sssa" = mkHomeConfiguration "x86_64-linux" "giova-sssa" "fbiondi";
      };
      overlays = import ./overlays { inherit inputs; };

      templates = import ./templates {};
    };
}
