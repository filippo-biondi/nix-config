{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.system.boot.raspberry;
in {
  options.ccg.system.boot.raspberry.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
  };
}
