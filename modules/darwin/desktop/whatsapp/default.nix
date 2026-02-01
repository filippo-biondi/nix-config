{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.desktop.whatsapp;
in {
  options.ccg.desktop.whatsapp.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "whatsapp"
    ];
  };
}
