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
    home.packages = with pkgs;
      if pkgs.stdenv.isDarwin
      then [
        vlc-bin
      ]
      else [
        spotify
        vlc
        obs-studio
      ];
  };
}
