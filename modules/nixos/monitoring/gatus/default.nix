{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.ccg.monitoring.gatus;
in {
  options.ccg.monitoring.gatus = {
    enable = lib.ccg.mkBoolOpt' false;
    # Gatus endpoints, each checked every minute and alerting on Telegram
    endpoints = lib.ccg.mkOpt' (lib.types.listOf lib.types.attrs) [];
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      environmentFile = config.sops.templates."gatus.env".path;
      settings = {
        # 8080 is Gerrit's on server-msi. The page is reachable through the tailnet
        web.port = 8090;
        alerting.telegram = {
          token = "\${TELEGRAM_TOKEN}";
          id = "\${TELEGRAM_CHAT_ID}";
          # Not the tailnet's DNS, which is Blocky on server-msi: an alert that
          # server-msi is down has to get through
          client.dns-resolver = "tcp://9.9.9.9:53";
          default-alert.send-on-resolved = true;
        };
        endpoints = map (endpoint:
          {
            interval = "1m";
            alerts = [{type = "telegram";}];
          }
          // endpoint)
        cfg.endpoints;
      };
    };

    # The bot that sends the alerts, and the chat it sends them to
    sops.secrets = lib.genAttrs ["telegram/bot-token" "telegram/chat-id"] (_: {
      sopsFile = "${inputs.secrets}/secrets/telegram.yaml";
    });
    sops.templates."gatus.env".content = ''
      TELEGRAM_TOKEN=${config.sops.placeholder."telegram/bot-token"}
      TELEGRAM_CHAT_ID=${config.sops.placeholder."telegram/chat-id"}
    '';
  };
}
