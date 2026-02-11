{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.cli.direnv;
in {
  options.ccg.cli.direnv.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = lib.mkIf config.ccg.shells.zsh.enable true;
        enableNushellIntegration = lib.mkIf config.ccg.shells.nushell.enable true;
        nix-direnv.enable = true;
      };

      zsh.oh-my-zsh.plugins = ["direnv"];
    };
  };
}
