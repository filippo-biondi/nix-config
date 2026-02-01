{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.networking.core;
in {
  options.ccg.networking.core = {
    enable = lib.ccg.mkBoolOpt' false;
    hostname = lib.ccg.mkOpt' lib.types.str "";
  };

  config = lib.mkIf cfg.enable {
    networking.hostName = cfg.hostname;
    services.tailscale.enable = true;
    homebrew.casks = [
      "surfshark"
    ];
  };
}
