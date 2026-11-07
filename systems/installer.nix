{
  host,
  config,
  pkgs,
  ...
}: let
  users = config.ccg.usersCatalog.installer;
in {
  # A minimal system to deploy a host's real configuration onto. Imported by
  # the installer hosts: Snowfall only builds directories, so this file isn't a host
  ccg.users = users;

  ccg.system.base.enable = true;

  ccg.networking.core = {
    hostname = host;
    enable = true;
  };

  ccg.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
    sbctl
  ];

  security.sudo.wheelNeedsPassword = false;
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
}
