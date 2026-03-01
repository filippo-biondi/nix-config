{
  config,
  lib,
  ...
}: let
  cfg = config.ccg.cli.zoxide;
in {
  options.ccg.cli.zoxide.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true; # This will be managed by the shell module (e.g. fish, zsh)
    };
  };
}
