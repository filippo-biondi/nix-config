{
  config,
  lib,
  ...
}:
with lib.ccg; let
  cfg = config.ccg.hardware.battery;
in {
  options.ccg.hardware.battery = {
    enable = mkBoolOpt' false;
  };

  config = lib.mkIf cfg.enable {
    # Enable TLP (better than gnomes internal power manager)
    services.tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };

    # Disable GNOMEs power management
    services.power-profiles-daemon.enable = false;

    # Enable powertop
    powerManagement.powertop.enable = true;

    # Enable thermald (only necessary if on Intel CPUs)
    services.thermald.enable = true;
  };
}
