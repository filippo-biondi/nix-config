{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.desktop.media;
in {
  options.ccg.desktop.media.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      spotify
      vlc
      obs-studio
    ];
  };
}
