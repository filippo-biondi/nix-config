{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.shells.fish;
in {
  options.ccg.shells.fish.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    ccg.cli.fzf.enable = true;

    ccg.cli.zoxide.enable = true;

    programs.fish = {
      enable = true;

      shellAbbrs = {
        ll = "ls -lh";
      };

      interactiveShellInit = ''
        set -g fish_greeting
        fish_vi_key_bindings

        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block
      '';

      plugins = [
        {
          name = "plugin-git";
          inherit (pkgs.fishPlugins.plugin-git) src;
        }
        {
          name = "autopair";
          inherit (pkgs.fishPlugins.autopair) src;
        }
        {
          name = "puffer";
          inherit (pkgs.fishPlugins.puffer) src;
        }
      ];
    };

    ccg.cli.starship.enable = true;
  };
}
