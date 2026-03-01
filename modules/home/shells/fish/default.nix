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

      binds = {
        "super-backspace" = {
          command = "backward-kill-line";
          mode = "insert";
        };
        "super-right" = {
          command = "end-of-line";
          mode = "insert";
        };
        "super-left" = {
          command = "beginning-of-line";
          mode = "insert";
        };
      };

      interactiveShellInit = ''
        set -g fish_greeting
        fish_vi_key_bindings

        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block

        bind --mode default super-right end-of-line
        bind --mode visual super-right end-of-line
        bind --mode default super-left beginning-of-line
        bind --mode visual super-left beginning-of-line
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
        {
          name = "symmetric-ctrl-z";
          src = pkgs.fetchFromGitHub {
            owner = "mattmc3";
            repo = "symmetric-ctrl-z";
            rev = "c093070400fe75870e466f69b09d94bddd688d2c";
            hash = "sha256-4UOereE9lE2/cPRPtLMLAOY9nFsOGXJs9+ercRZUwek=";
          };
        }
      ];
    };

    ccg.cli.starship.enable = true;
  };
}
