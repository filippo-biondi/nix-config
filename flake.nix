{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    
    unstable-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland.url = "github:hyprwm/Hyprland";
    
    nvim.url = "github:filippo-biondi/nvim-config";
    # nvim.url = "path:/home/filippo/nvim-config";

    connecttunnel-nix.url = "github:iannisimo/connecttunnel-nix";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: 
    let system = "x86_64-linux"; in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
	        specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
          ];
        };
      };
      homeConfigurations."filippo@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          config.allowUnfree = true; # Enable unfree packages
          inherit system;
        };
        extraSpecialArgs = {
          pkgs-unstable = import inputs.unstable-nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./home.nix
        ];
      };
    };
}
