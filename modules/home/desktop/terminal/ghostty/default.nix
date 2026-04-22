{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.ccg.desktop.terminal.ghostty;
in {
  options.ccg.desktop.terminal.ghostty.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = pkgs.ghostty-bin;
      installVimSyntax = true;
      enableFishIntegration = config.ccg.shells.fish.enable;
      enableZshIntegration = config.ccg.shells.zsh.enable;
      settings = {
        command = "${pkgs.fish}/bin/fish --login --interactive";
        theme = "catppuccin-mocha";
        font-size = 18;
        maximize = true;
        auto-update-channel = "tip"; # wait for for new ghostty release
        macos-option-as-alt = true;
        keybind = [
          # Entry point
          "alt+v=activate_key_table:vim"

          # Key table definition
          "vim/"

          # Line movement
          "vim/j=scroll_page_lines:1"
          "vim/k=scroll_page_lines:-1"

          # Page movement
          "vim/ctrl+d=scroll_page_down"
          "vim/ctrl+u=scroll_page_up"
          "vim/ctrl+f=scroll_page_down"
          "vim/ctrl+b=scroll_page_up"
          "vim/shift+j=scroll_page_down"
          "vim/shift+k=scroll_page_up"

          # Jump to top/bottom
          "vim/g>g=scroll_to_top"
          "vim/shift+g=scroll_to_bottom"

          # Search
          "vim/slash=start_search"
          "vim/n=navigate_search:next"

          # Copy mode / selection
          "vim/v=copy_to_clipboard"
          "vim/y=copy_to_clipboard"

          # Command Palette
          "vim/shift+semicolon=toggle_command_palette"

          # Exit the vim key table
          "vim/escape=deactivate_key_table"
          "vim/q=deactivate_key_table"
          "vim/i=deactivate_key_table"

          # Catch unbound keys so they don't fall through
          "vim/catch_all=ignore"
        ];
        # window.startup_mode = "Maximized";
        # keyboard.bindings = [
        #   {
        #     key = "C";
        #     mods = "Command";
        #     mode = "Alt";
        #     action = "ReceiveChar";
        #   }
        #   {
        #     key = "C";
        #     mods = "Command";
        #     mode = "~Alt";
        #     action = "Copy";
        #   }
        #   {
        #     key = "Back";
        #     mods = "Alt";
        #     mode = "~Alt";
        #     chars = "\\u0017";
        #   }
        #   {
        #     key = "Back";
        #     mods = "Alt";
        #     mode = "Alt";
        #     chars = "\\u001b\\u007f";
        #   }
        #   {
        #     key = "ArrowLeft";
        #     mods = "Alt";
        #     mode = "Vi|~Search";
        #     action = "SemanticLeft";
        #   }
        #   {
        #     key = "ArrowRight";
        #     mods = "Alt";
        #     mode = "Vi|~Search";
        #     action = "SemanticRight";
        #   }
        # ];
      };
      themes = {
        catppuccin-mocha = {
          background = "1e1e2e";
          cursor-color = "f5e0dc";
          foreground = "cdd6f4";
          palette = [
            "0=#45475a"
            "1=#f38ba8"
            "2=#a6e3a1"
            "3=#f9e2af"
            "4=#89b4fa"
            "5=#f5c2e7"
            "6=#94e2d5"
            "7=#bac2de"
            "8=#585b70"
            "9=#f38ba8"
            "10=#a6e3a1"
            "11=#f9e2af"
            "12=#89b4fa"
            "13=#f5c2e7"
            "14=#94e2d5"
            "15=#a6adc8"
          ];
          selection-background = "353749";
          selection-foreground = "cdd6f4";
        };
      };
    };
  };
}
