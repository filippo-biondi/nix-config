{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.cli;
in {
  options.ccg.cli.enable = lib.mkEnableOption "Enable all cli modules";

  config = lib.mkIf cfg.enable {
    ccg.cli = {
      git.enable = true;
      direnv.enable = true;
      ssh.enable = true;
      utils.enable = true;
      devenv.enable = true;
    };
  };
}
