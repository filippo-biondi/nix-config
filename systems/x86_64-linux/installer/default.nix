{
  host,
  config,
  pkgs,
  lib,
  ...
}: {
  ccg.users = config.ccg.usersCatalog.${host};
  users.users.root.openssh.authorizedKeys.keys = config.ccg.usersCatalog.${host}.filippo.sshKeys;

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
  services.openssh.settings.PermitRootLogin = lib.mkForce "without-password";
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  # dummy values to pass checks
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };
  boot.loader.grub.enable = false;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.05";
  # ======================== DO NOT CHANGE THIS ========================
}
