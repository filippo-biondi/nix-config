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

    sops.secrets."interpelli-bot-env" = {
      sopsFile = "${inputs.secrets}/secrets/interpelli-bot.yaml";
    };
  };
}
