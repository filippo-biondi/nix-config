{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.cli.fzf;
in {
  options.ccg.cli.fzf.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
      fd
      eza
    ];

    programs.fzf = {
      enable = true;
      enableFishIntegration = true; # This will be managed by the shell module (e.g. fish, zsh)

      defaultOptions = ["--height 40%" "--layout=reverse" "--border"];

      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --style=numbers --color=always --line-range :500 {}'"
      ];

      changeDirWidgetOptions = [
        "--preview '${pkgs.eza}/bin/eza --tree --color=always {} | head -200'"
      ];
    };
  };
}
