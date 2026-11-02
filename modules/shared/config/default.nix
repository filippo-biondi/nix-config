{
  inputs,
  lib,
  ...
}: {
  nix = {
    registry = lib.mapAttrs (_: flake: {inherit flake;}) (
      lib.filterAttrs (_: lib.isType "flake") inputs
    );
    settings = {
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      trusted-users = [
        "@wheel"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
