{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.cli.devenv;
in {
  options.ccg.cli.devenv.enable = lib.ccg.mkBoolOpt' true;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];
  };
}
