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
      # Reached through tailscale serve only
      host = "127.0.0.1";
      accelerationDevices = null;
      machine-learning.enable = true;
    };
    # Its originals and its database: it regenerates thumbnails and videos
    ccg.backup = {
      paths = map (dir: "${config.services.immich.mediaLocation}/${dir}") ["upload" "library" "profile"];
      dumps.immich = {
        user = "postgres";
        command = ["${config.services.postgresql.package}/bin/pg_dump" "--format=custom" "--compress=0" "immich"];
      };
    };

    # https://<host>.<tailnet>:8443, with a certificate from Tailscale
    systemd.services.immich-tailscale-serve = {
      after = ["tailscaled.service" "immich-server.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = 10;
      };
      script = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=8443 http://127.0.0.1:${toString config.services.immich.port}";
    };
  };
}
