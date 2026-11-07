{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ../../installer.nix
    # Builds config.system.build.sdImage, which boots on a Raspberry Pi 3 or 4
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # The SD card profile adds ZFS, which nothing here uses
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "26.05";
  # ======================== DO NOT CHANGE THIS ========================
}
