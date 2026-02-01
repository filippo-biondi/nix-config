{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.desktop.games;
in {
  options.ccg.desktop.games.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "steam"
    ];
  };
}
