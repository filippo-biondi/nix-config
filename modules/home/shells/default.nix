{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.shells;
in {
  options.ccg.shells.enable = lib.mkEnableOption "Enable all shells modules";

  config = lib.mkIf cfg.enable {
    ccg.shells = {
      zsh.enable = true;
      nushell.enable = true;
    };
  };
}
