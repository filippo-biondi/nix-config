{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.ccg.hardware.smartd;
  secret = name: config.sops.secrets."telegram/${name}".path;

  # smartd mails its warnings: send them to Telegram instead, without the
  # smartctl report that comes with them
  mailer = pkgs.writeShellApplication {
    name = "smartd-telegram";
    runtimeInputs = [pkgs.coreutils pkgs.curl];
    text = ''
      cat >/dev/null
      text="$SMARTD_SUBJECT"$'\n\n'"$SMARTD_FULLMESSAGE"
      # The URL, with the token, goes through the input, out of the process list
      printf 'url = "https://api.telegram.org/bot%s/sendMessage"\n' "$(cat ${secret "bot-token"})" |
        curl --config - --silent --show-error --fail --max-time 30 --output /dev/null \
          --data-urlencode "chat_id=$(cat ${secret "chat-id"})" \
          --data-urlencode "text=''${text:0:4000}"
    '';
  };
in {
  options.ccg.hardware.smartd.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.smartd = {
      enable = true;
      # Every disk: a short self-test each night at 2, a long one on the 1st
      # of each month at 3, and an alert at 60°C
      defaults.autodetected = "-a -o on -S on -s (S/../.././02|L/../01/./03) -W 0,50,60";
      notifications.mail = {
        enable = true;
        mailer = lib.getExe mailer;
      };
    };

    # The bot that sends the alerts, and the chat it sends them to
    sops.secrets = lib.genAttrs ["telegram/bot-token" "telegram/chat-id"] (_: {
      sopsFile = "${inputs.secrets}/secrets/telegram.yaml";
    });
  };
}
