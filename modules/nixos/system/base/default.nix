{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.ccg.system.base;
in {
  imports = [
    ../../../shared/config
  ];

  options.ccg.system.base.enable = lib.ccg.mkBoolOpt' true;

  config = lib.mkIf cfg.enable {
    console.keyMap = "qwerty/us-acentos";

    # Timezone
    time.timeZone = "Europe/Rome";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "it_IT.UTF-8";
        LC_IDENTIFICATION = "it_IT.UTF-8";
        LC_MEASUREMENT = "it_IT.UTF-8";
        LC_MONETARY = "it_IT.UTF-8";
        LC_NAME = "it_IT.UTF-8";
        LC_NUMERIC = "it_IT.UTF-8";
        LC_PAPER = "it_IT.UTF-8";
        LC_TELEPHONE = "it_IT.UTF-8";
        LC_TIME = "it_IT.UTF-8";
      };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      sudo
      gcc
      glib
      wget
      curl
      unzip
      mesa
      killall
    ];

    programs.bash.enable = true;
    programs.zsh.enable = true;
    programs.fish.enable = true;

    services.devmon.enable = true;
    services.locate.enable = true;

    # Prevent sleep
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    security.sudo = {
      enable = true;
      extraConfig = ''
        Defaults env_keep += "SSH_AUTH_SOCK"
      '';
    };
  };
}
