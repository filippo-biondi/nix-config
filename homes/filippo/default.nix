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

  ccg.coding.enable = lib.mkDefault true;
  ccg.cli.enable = lib.mkDefault true;
  ccg.shells.enable = lib.mkDefault true;
  ccg.desktop.terminal.alacritty.enable = lib.mkDefault true;
  ccg.desktop.terminal.ghostty.enable = lib.mkDefault true;

  ccg.cli.git.user = config.ccg.usersCatalog.${host}.${username};
  ccg.cli.ssh.gerrit = {
    enable = true;
    user = "biondifilippo00@gmail.com";
  };

  # sops reaches the age key on the MacBook through its key service, which
  # the SSH connection forwards to this socket
  home.sessionVariables.SOPS_KEYSERVICE = "unix://${config.home.homeDirectory}/.sops-keyservice.sock";

  home.stateVersion = "24.05";
}
