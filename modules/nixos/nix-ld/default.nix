{
  config,
  lib,
  ...
}:
with lib.ccg; let
  cfg = config.ccg.apps.tools.nix-ld;
in {
  options.ccg.apps.tools.nix-ld = {
    enable = mkBoolOpt' false;
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
