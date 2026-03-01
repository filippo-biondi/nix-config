{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.desktop.utils;
in {
  options.ccg.desktop.utils.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        zotero
        neovide
        bitwarden-desktop
        bitwarden-cli
      ]
      ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
        stable.kicad-small
        wl-clipboard
      ];
  };
}
