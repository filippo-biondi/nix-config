{
  config,
  host,
  lib,
  modulesPath,
  ...
}: {
  # The same layout and boot setup as the SD card it was flashed with, so
  # deploying keeps it bootable
  imports = ["${modulesPath}/installer/sd-card/sd-image-aarch64.nix"];

  # The SD card profile adds ZFS, which nothing here uses
  boot.supportedFilesystems.zfs = lib.mkForce false;

  ccg.system.base.enable = true;

  ccg.users = config.ccg.usersCatalog.${host};
  ccg.openssh.enable = true;

  ccg.networking.core = {
    enable = true;
    hostname = host;
  };

  ccg.networking.tailscale = {
    enable = true;
    withKey = true;
    # An exit through wherever the Pi is
    exitNode = true;
  };

  # A Raspberry Pi 3B+ has 1 GB of RAM
  zramSwap.enable = true;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "26.05";
  # ======================== DO NOT CHANGE THIS ========================
}
