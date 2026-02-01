{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.docker;
in {
  options.ccg.docker.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
  };
}
