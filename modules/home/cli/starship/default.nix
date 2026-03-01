{
  config,
  lib,
  ...
}: let
  cfg = config.ccg.cli.starship;
in {
  options.ccg.cli.starship.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = config.ccg.shells.fish.enable;
      enableZshIntegration = config.ccg.shells.zsh.enable;
      enableNushellIntegration = config.ccg.shells.nushell.enable;
      settings = {
        add_newline = true;
        package.disabled = true;
        nix_shell.disabled = true;
        cmake.disabled = true;
        directory = {
          truncation_length = 0;
          fish_style_pwd_dir_length = 1;
        };
      };
    };
  };
}
