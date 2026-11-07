{
  host,
  config,
  pkgs,
  lib,
  ...
}: let
  users = config.ccg.usersCatalog.installer;
in {
  # A minimal system to deploy a host's real configuration onto, as one
  # installer-<arch> host per architecture. Snowfall only builds directories,
  # so this file isn't a host itself
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

  # nixos-anywhere logs in as root to partition and install a new machine from here
  users.users.root.openssh.authorizedKeys.keys = users.filippo.sshKeys;
  services.openssh.settings.PermitRootLogin = lib.mkForce "without-password";

  # Placeholders for the plain system: every image variant sets its own
  fileSystems."/" = lib.mkDefault {
    device = "/dev/null";
    fsType = "ext4";
  };
  boot.loader.grub.enable = lib.mkDefault false;

  # The sd-card variant adds ZFS, which nothing here uses
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
