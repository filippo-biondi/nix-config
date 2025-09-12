{
  nixpkgs,
  inputs,
  outputs,
  self,
}: let
  inherit (inputs) home-manager nix-darwin;
  get_users = hostname:
    let config = import ../hosts {};
    in nixpkgs.lib.mapAttrs (name: value: value // { username = name; }) config.${hostname};


  _mkConfiguration = type: system: hostname: username:
    let
      configFolder = "${self}/config/${type}";
      featuresFolder = "${self}/features";
      users = get_users hostname;
      userConfig = users.${username};
      suffix_imports = suffix: list:
        let
          add_suffix = suffix: str:
            if builtins.pathExists "${str}/default.nix" then str
            else "${str}/${suffix}";
        in
          builtins.map (x: add_suffix suffix x) list;
      sharedSpecialArgs = {
        inherit self inputs outputs system hostname userConfig configFolder featuresFolder;
        suffix_imports = suffix_imports type;
      };
      home-manager-args = {
          home-manager.extraSpecialArgs = sharedSpecialArgs // {
            configFolder = "${self}/config/home-manager";
            suffix_imports = suffix_imports "home-manager";
          };
          home-manager.users.${username} = import "${self}/hosts/${hostname}/home/${username}";
        };

    in
      if type=="nixos" then nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = sharedSpecialArgs // { inherit users; };
        modules = [
          "${self}/hosts/${hostname}"
          inputs.connecttunnel-nix.nixosModule
          inputs.interpelli-bot.nixosModules."${system}".default
          home-manager.nixosModules.home-manager home-manager-args
        ];
      }

      else if type=="darwin" then nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = sharedSpecialArgs // { inherit users; };
        modules = [
          "${self}/hosts/${hostname}"
          inputs.nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager home-manager-args
        ];
      }

      else home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        extraSpecialArgs = sharedSpecialArgs;
        modules = [
          "${self}/hosts/${hostname}/home/${username}"
        ];
      };
in {

    nixos = {
      mkConfiguration = _mkConfiguration "nixos";
    };

    darwin = {
      mkConfiguration = _mkConfiguration "darwin";
    };

    home = {
      mkConfiguration = _mkConfiguration "home-manager";
    };
}
