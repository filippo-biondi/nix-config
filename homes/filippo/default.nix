{
  lib,
  config,
  host,
  ...
}: let
  username = config.snowfallorg.user.name;
in {
  ccg.desktop.social.enable = lib.mkDefault true;
  ccg.desktop.media.enable = lib.mkDefault true;
  ccg.desktop.utils.enable = lib.mkDefault true;

  ccg.shells.nushell.enable = lib.mkDefault true;

  ccg.cli.git.user = config.ccg.usersCatalog.${host}.${username};

  home.stateVersion = "24.05";
}
