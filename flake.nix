{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
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

      mkDarwinConfiguration = system: hostname: username:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = get_user username;
            darwinModules = "${self}/modules/darwin";
          };
          modules = [
            ./hosts/${hostname}
            inputs.nix-homebrew.darwinModules.nix-homebrew
             home-manager.darwinModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs outputs;
                userConfig = get_user username;
                nhModules = "${self}/modules/home-manager";
              };
              home-manager.users.${username} = import ./home/${hostname}/${username};
            }
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
        "macbook-pro" = mkDarwinConfiguration "aarch64-darwin" "macbook-pro" "filippo";
      };


      homeConfigurations = {
        "filippo@msi" = mkHomeConfiguration "x86_64-linux" "msi" "filippo";
        "fbiondi@giova-sssa" = mkHomeConfiguration "x86_64-linux" "giova-sssa" "fbiondi";
      };
      overlays = import ./overlays { inherit inputs; };
    };
}
