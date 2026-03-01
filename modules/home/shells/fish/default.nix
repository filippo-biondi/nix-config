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
    home.packages = with pkgs; [
      # Required for the fzf previews to work
      bat
      fd
      eza
    ];

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;

      # Optional: Restore the "fancy" FZF behavior manually
      # This mimics what fzf-fish does but using standard Nix tools
      defaultOptions = ["--height 40%" "--layout=reverse" "--border"];

      # Preview files with 'bat' when using Ctrl+T
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --style=numbers --color=always --line-range :500 {}'"
      ];

      # Preview directories with 'eza' (modern ls) when using Alt+C
      changeDirWidgetOptions = [
        "--preview '${pkgs.eza}/bin/eza --tree --color=always {} | head -200'"
      ];
    };

    # 3. Zoxide
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

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

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
        package.disabled = true;
        nix_shell.disabled = true;
        cmake.disabled = true;
      };
    };
  };
}
