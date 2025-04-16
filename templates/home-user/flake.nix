{
  description = "Home-Manager flake template for a user";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    system = "x86_64-linux";
    username = "REPLACE_ME"; # <-- users should replace this!
    homeDirectory = "/home/${username}";
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit system;
      pkgs = import nixpkgs { inherit system; };
      modules = [
        ./home.nix
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
      ];
    };
  };
}

