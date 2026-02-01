{
  config,
  lib,
  ...
}: let
  cfg = config.ccg.system.boot.bios;
in {
  options.ccg.system.boot.bios = {
    enable = lib.ccg.mkBoolOpt' false;
    device = lib.ccg.mkOpt' lib.types.str "/dev/sda";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
  };
}
