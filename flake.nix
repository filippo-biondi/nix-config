{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-nightly.url = "github:nixos/nixpkgs/nixos-unstable";

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

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
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

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nvim.url = "github:filippo-biondi/nvim-config";

    secrets.url = "git+ssh://git@github.com/filippo-biondi/nix-secrets.git";
    # secrets.url = "git+file:///path/to/nix-secrets";
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
      ];
      systems.modules.darwin = with inputs; [
        ./modules/shared
        ./modules/usersCatalog
        sops-nix.darwinModules.sops
        nix-homebrew.darwinModules.nix-homebrew
        nix-rosetta-builder.darwinModules.default
      ];
      homes.modules = [
        ./modules/usersCatalog
      ];

      outputs-builder = channels: let
        pkgs = channels.nixpkgs;
        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./overlays/treefmt/treefmt.nix;
      in {
        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check inputs.self;
        };
      };
    };
}
