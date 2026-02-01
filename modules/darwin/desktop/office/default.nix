{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.desktop.office;
in {
  options.ccg.desktop.office.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "microsoft-powerpoint"
      "microsoft-excel"
      "microsoft-word"
    ];
  };
}
