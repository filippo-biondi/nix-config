{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ccg.monitoring.health;

  health = pkgs.writers.writePython3 "health" {flakeIgnore = ["E501"];} (builtins.readFile ./health.py);
  settings = pkgs.writeText "health.json" (builtins.toJSON {
    inherit (cfg) threshold;
    inherit (cfg.notifier) send;
    state = "/var/lib/health/reported.json";
  });
in {
  options.ccg.monitoring.health = {
    enable = lib.ccg.mkBoolOpt' false;
    # Told when a filesystem fills up or a systemd unit fails, and when that's resolved
    notifier = lib.mkOption {type = lib.ccg.notifierType;};
    # How full a filesystem may get, in percent
    threshold = lib.ccg.mkOpt' lib.types.int 85;
  };

  config = lib.mkIf cfg.enable {
    systemd.services.health = {
      path = [config.systemd.package];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${health} ${settings}";
        StateDirectory = "health";
      };
    };
    systemd.timers.health = {
      wantedBy = ["timers.target"];
      timerConfig.OnCalendar = "*:0/15";
    };
  };
}
