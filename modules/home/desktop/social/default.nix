{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.desktop.social;
in {
  options.ccg.desktop.social.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        discord
        element-desktop
        telegram-desktop
      ]
      ++ (
        if pkgs.stdenv.isDarwin
        then [
          signal-desktop-bin
          firefox-bin
        ]
        else [
          signal-desktop
        ]
      );

    programs.firefox.enable = lib.mkIf pkgs.stdenv.isLinux true;
  };
}
