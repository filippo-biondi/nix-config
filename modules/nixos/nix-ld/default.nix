{
  config,
  lib,
  ...
}:
with lib;
with lib.ccg; let
  cfg = config.ccg.apps.tools.nix-ld;
in {
  options.ccg.apps.tools.nix-ld = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
