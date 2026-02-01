{
  config,
  lib,
  ...
}: let
  cfg = config.ccg.system.boot.efi;
in {
  options.ccg.system.boot.efi = {
    enable = lib.ccg.mkBoolOpt' false;
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
