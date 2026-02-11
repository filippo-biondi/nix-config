{
  config,
  host,
  ...
}: {
  imports = [./hardware-configuration.nix];

  ccg.system.base.enable = true;
  ccg.system.boot.bios.enable = true;

  ccg.users = config.ccg.usersCatalog.${host};
  ccg.openssh.enable = true;
  ccg.docker.enable = true;

  ccg.networking.wifi.enable = false;
  ccg.networking.core = {
    enable = true;
    hostname = host;
  };

  ccg.networking.tailscale = {
    enable = true;
    withKey = true;
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.05";
  # ======================== DO NOT CHANGE THIS ========================
}
