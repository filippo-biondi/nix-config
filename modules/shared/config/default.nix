{
  inputs,
  lib,
  pkgs,
  ...
}: {
  nix = {
    registry = lib.mapAttrs (_: flake: {inherit flake;}) (
      lib.filterAttrs (_: lib.isType "flake") inputs
    );
    settings = {
      experimental-features = "nix-command flakes";
      substituters = [
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      trusted-users = ["@admin"];
    };
    optimise.automatic = true;
    gc =
      {
        automatic = true;
        options = "--delete-older-than 30d";
      }
      // (
        if pkgs.stdenv.isDarwin
        then {
          interval = {
            Weekday = 7;
          };
        }
        else {
          dates = "weekly";
        }
      );
  };
}
