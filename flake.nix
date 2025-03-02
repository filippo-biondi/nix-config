{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim.url = "github:filippo-biondi/nvim-config";
    # nvim.url = "path:/home/filippo/.config/nvim";

    connecttunnel-nix.url = "github:iannisimo/connecttunnel-nix";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      inherit (self) outputs;

      get_user = name:
        let users = rec {
          filippo = {
            fullName = "Filippo Biondi";
            email = "filibiondi2000@gmail.com";
            # gitKey = "C5810093"; ??
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
          inputs.catppuccin.homeManagerModules.catppuccin
        ];
      };
    in {
      nixosConfigurations = {
        msi = mkNixosConfiguration "x86_64-linux" "msi" "filippo";
      };

      homeConfigurations = {
        "filippo@msi" = mkHomeConfiguration "x86_64-linux" "msi" "filippo";
        "fbiondi@giova-sssa" = mkHomeConfiguration "x86_64-linux" "giova-sssa" "fbiondi";
      };
      overlays = import ./overlays { inherit inputs; };
    };
}
