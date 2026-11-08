{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.self-hosting.interpelli-bot;
in {
  options.ccg.self-hosting.interpelli-bot.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.interpelli-bot = {
      enable = true;
      environmentFile = config.sops.secrets."interpelli-bot-env".path;
    };
    ccg.backup = {
      services.interpelli-bot.paths = ["/var/lib/interpelli-bot"];
      dumps.interpelli-bot = {
        user = "postgres";
        command = ["${config.services.postgresql.package}/bin/pg_dump" "--format=custom" "--compress=0" "interpelli-bot"];
      };
    };

    sops.secrets."interpelli-bot-env" = {
      sopsFile = "${inputs.secrets}/secrets/interpelli-bot.yaml";
    };
  };
}
