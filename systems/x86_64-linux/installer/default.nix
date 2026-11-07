{
  config,
  lib,
  ...
}: {
  imports = [../../installer.nix];

  # nixos-anywhere logs in as root to partition and install a new machine from here
  users.users.root.openssh.authorizedKeys.keys = config.ccg.usersCatalog.installer.filippo.sshKeys;
  services.openssh.settings.PermitRootLogin = lib.mkForce "without-password";

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
