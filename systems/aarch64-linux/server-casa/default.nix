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

  # Watches the other servers, from outside them
  ccg.monitoring.gatus = let
    inherit (config.ccg.networking.tailscale) tailnet;
    msi = "server-msi.${tailnet}";
  in {
    enable = true;
    endpoints = [
      {
        name = "Immich";
        group = "server-msi";
        url = "https://${msi}:8443/api/server/ping";
        # Tailscale renews the certificate well before it expires
        conditions = ["[STATUS] == 200" "[CERTIFICATE_EXPIRATION] > 168h"];
      }
      {
        name = "Gerrit";
        group = "server-msi";
        url = "http://${msi}/config/server/version";
        conditions = ["[STATUS] == 200"];
      }
      {
        name = "Blocky";
        group = "server-msi";
        url = msi;
        dns = {
          query-name = "example.org";
          query-type = "A";
        };
        conditions = ["[DNS_RCODE] == NOERROR"];
      }
      {
        name = "SSH";
        group = "server-msi";
        url = "ssh://${msi}:22";
        conditions = ["[CONNECTED] == true"];
      }
      {
        name = "SSH";
        group = "server-stella";
        url = "ssh://server-stella.${tailnet}:22";
        conditions = ["[CONNECTED] == true"];
      }
    ];
  };

  # A Raspberry Pi 3B+ has 1 GB of RAM
  zramSwap.enable = true;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "26.05";
  # ======================== DO NOT CHANGE THIS ========================
}
