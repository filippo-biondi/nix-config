{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.ccg.desktop.terminal.alacritty;
in {
  options.ccg.desktop.terminal.alacritty.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/alacritty/themes".source = pkgs.fetchgit {
        url = "https://github.com/alacritty/alacritty-theme";
        rev = "69d07c3bc280add63906a1cebf6be326687bc9eb";
        sha256 = "sha256-O7kMi5m/fuqQZXmAMZ0hXF1ANUifK843Yfq/pEDCspE=";
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        terminal.shell = {
          program = "${pkgs.fish}/bin/fish";
          args = ["--login"];
        };
        general.import = ["~/.config/alacritty/themes/themes/catppuccin_mocha.toml"];
        env.TERM = "xterm-256color";
        font = {
          normal.family = "JetBrainsMono Nerd Font";
          size = 18;
        };
        window.startup_mode = "Maximized";
        keyboard.bindings = [
          {
            key = "C";
            mods = "Command";
            mode = "Alt";
            action = "ReceiveChar";
          }
          {
            key = "C";
            mods = "Command";
            mode = "~Alt";
            action = "Copy";
          }
          {
            key = "Back";
            mods = "Alt";
            mode = "~Alt";
            chars = "\\u0017";
          }
          {
            key = "Back";
            mods = "Alt";
            mode = "Alt";
            chars = "\\u001b\\u007f";
          }
          {
            key = "ArrowLeft";
            mods = "Alt";
            mode = "Vi|~Search";
            action = "SemanticLeft";
          }
          {
            key = "ArrowRight";
            mods = "Alt";
            mode = "Vi|~Search";
            action = "SemanticRight";
          }
        ];
        mouse.hide_when_typing = true;
      };
    };
  };
}
