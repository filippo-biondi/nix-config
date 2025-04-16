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
        let config = rec {
          msi = {
            filippo = {
              fullName = "Filippo Biondi";
              email = "filibiondi2000@gmail.com";
              sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArV7DUbiqZYLwtF5tZVQTskVPYJzaltXqZzVYJrxJwy" ];
              shell = "zsh";
            };
            matteo = {
              fullName = "Matteo Tolloso";
              sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICYhWjAETWEB1YdT3Hn1xDEiJWbtAScaoi5+auEq1SQM" ];
              shell = "bash";
            };
            vornao = {
              fullName = "Luca Miglior";
              sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF65PNkzAPb12J2BV/Jzc79+BZ8RIlLJPDz6tOta21Cj" ];
              shell = "bash";
            };
          };

          server-stella = msi;

          giova-sssa = {
            fbiondi = msi.filippo // {
              email = "filippo.biondi@santannapisa.it";
              sshKeys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5XH2x57j86zBf2eMDkEhjHBeIOuGdxWsc358WfcQT"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArV7DUbiqZYLwtF5tZVQTskVPYJzaltXqZzVYJrxJwy"
              ];
            };
          };

          macbook-pro = {
            filippo = msi.filippo // {
              sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5XH2x57j86zBf2eMDkEhjHBeIOuGdxWsc358WfcQT" ];
            };
          };
        };
        in nixpkgs.lib.mapAttrs (name: value: value // { username = name; }) config.${hostname};

      home-manager-args = system: hostname: username: userConfig: {
        home-manager.extraSpecialArgs = {
          inherit inputs outputs system userConfig;
          nhModules = "${self}/modules/home-manager";
        };
        home-manager.users.${username} = import ./home/${hostname}/${username};
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
          nhModules = "${self}/modules/home-manager";
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
