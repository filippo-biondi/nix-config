{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.ccg.desktop.ux;
in {
  options.ccg.desktop.ux.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rectangle
      raycast
      mos
    ];

    homebrew = {
      taps = [];
      brews = [];
      casks = [
        "battery"
        "macs-fan-control"
      ];
    };
  };
}
