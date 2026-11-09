{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ccg.notify.telegram;
  secret = name: config.sops.secrets."telegram/${name}".path;

  send = pkgs.writeShellApplication {
    name = "telegram-send";
    runtimeInputs = [pkgs.coreutils pkgs.curl];
    text = ''
      text="${config.networking.hostName}: $*"
      # The URL, with the token, goes through the input, out of the process list.
      # Telegram's address comes from Quad9, not the local DNS, which may be
      # Blocky on server-msi: alerts still get through while it's down
      printf 'url = "https://api.telegram.org/bot%s/sendMessage"\n' "$(cat ${secret "bot-token"})" |
        curl --config - --doh-url https://9.9.9.9/dns-query \
          --silent --show-error --fail --max-time 30 --output /dev/null \
          --data-urlencode "chat_id=$(cat ${secret "chat-id"})" \
          --data-urlencode "text=''${text:0:4000}"
    '';
  };
in {
  options.ccg.notify.telegram = {
    enable = lib.ccg.mkBoolOpt' false;
    # A sops file with telegram.bot-token and telegram.chat-id
    sopsFile = lib.ccg.mkOpt' lib.types.path null;
    notifier = lib.mkOption {
      type = lib.ccg.notifierType;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    ccg.notify.telegram.notifier.send = lib.getExe send;

    sops.secrets = lib.genAttrs ["telegram/bot-token" "telegram/chat-id"] (_: {
      inherit (cfg) sopsFile;
    });
  };
}
