{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.desktop.social;
in {
  options.ccg.desktop.social.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
      telegram-desktop
      signal-desktop
    ];

    programs.firefox = {
      enable = true;
      # Keep the existing profile where it is: home.stateVersion 26.05 moves the default
      configPath = ".mozilla/firefox";
    };
  };
}
