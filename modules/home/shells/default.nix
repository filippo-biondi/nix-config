{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.shells;
in {
  options.ccg.shells.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    ccg.shells = {
      zsh.enable = false;
      fish.enable = true;
      nushell.enable = false;
    };
  };
}
