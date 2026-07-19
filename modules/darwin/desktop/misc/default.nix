{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.desktop.misc;
in {
  options.ccg.desktop.misc.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "firefox"
      "balenaetcher"
      "kicad"
      "freecad"
      "orcaslicer"
      "arduino-ide"
    ];

    environment.systemPackages = with pkgs; [
      utm
    ];
  };
}
