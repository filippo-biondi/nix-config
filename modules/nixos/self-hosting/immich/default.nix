{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.self-hosting.immich;
in {
  options.ccg.self-hosting.immich.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      package = pkgs.nightly.immich;
      host = "0.0.0.0";
      accelerationDevices = null;
      machine-learning.enable = true;
    };
  };
}
