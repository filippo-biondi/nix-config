{
  host,
  config,
  ...
}: let
in {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  ccg.system.boot.efi.enable = true;
  ccg.system.base.enable = true;

  ccg.hardware.battery.enable = true;

  ccg.users = config.ccg.usersCatalog.${host};
  ccg.openssh.enable = true;
  ccg.docker.enable = true;

  ccg.desktop.graphics.enable = true;
  ccg.hardware.nvidia.enable = true;
  ccg.system.print.enable = true;
  ccg.system.fonts.enable = true;
  ccg.networking.wifi.enable = true;
  ccg.networking.core = {
    hostname = host;
    enable = true;
  };

  ccg.games.factorio.enable = true;
  ccg.networking.surfshark.enable = false;
  ccg.networking.tailscale = {
    enable = true;
    withKey = true;
  };
  ccg.self-hosting.immich.enable = true;
  ccg.self-hosting.proxmox.enable = true;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.05";
  # ======================== DO NOT CHANGE THIS ========================
}
