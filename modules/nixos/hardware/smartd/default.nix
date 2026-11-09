{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ccg.hardware.smartd;

  # smartd mails its warnings: send them through the notifier instead, without
  # the smartctl report that comes with them
  mailer = pkgs.writeShellScript "smartd-notify" ''
    ${pkgs.coreutils}/bin/cat >/dev/null
    exec ${cfg.notifier.send} "$SMARTD_SUBJECT"$'\n\n'"$SMARTD_FULLMESSAGE"
  '';
in {
  options.ccg.hardware.smartd = {
    enable = lib.ccg.mkBoolOpt' false;
    notifier = lib.mkOption {type = lib.ccg.notifierType;};
  };

  config = lib.mkIf cfg.enable {
    services.smartd = {
      enable = true;
      # Every disk: a short self-test each night at 2, a long one on the 1st
      # of each month at 3, and an alert at 60°C
      defaults.autodetected = "-a -o on -S on -s (S/../.././02|L/../01/./03) -W 0,50,60";
      notifications.mail = {
        enable = true;
        inherit mailer;
      };
    };
  };
}
