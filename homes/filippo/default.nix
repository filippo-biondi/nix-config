{
  config,
  host,
  ...
}: let
  username = config.snowfallorg.user.name;
in {
  ccg.desktop.social.enable = true;
  ccg.desktop.media.enable = true;
  ccg.desktop.utils.enable = true;

  ccg.shells.nushell.enable = true;

  ccg.cli.git.user = config.ccg.usersCatalog.${host}.${username};

  home.stateVersion = "24.05";
}
