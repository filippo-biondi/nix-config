{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.docker;
in {
  options.ccg.docker.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.colima
      pkgs.docker
    ];
  };
}
