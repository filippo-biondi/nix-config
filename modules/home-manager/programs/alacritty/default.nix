{
  pkgs,
  ...
}: {
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
      general.import = [ "~/.config/alacritty/themes/themes/catppuccin_mocha.toml" ];
      env.TERM = "xterm-256color";
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 14;
      };
      window.startup_mode = "Maximized";
      keyboard.bindings = [
        # {
        #   key = "C";
        #   mods = "Control|Shift";
        #   mode = "Alt";
        #   action = "ReceiveChar";
        # }
        # {
        #   key = "C";
        #   mods = "Control|Shift";
        #   mode = "~Alt";
        #   action = "Copy";
        # }
        {
          key = "Back";
          mods = "Control";
          mode = "~Alt";
          chars = "\\u0008"; # double slash is needed because one disappear in the final toml file
        }
        {
          key = "End";
          mods = "Shift";
          action = "ReceiveChar";
        }

        {
          key = "ArrowLeft";
          mods = "Super";
          mode = "Vi|~Search";
          action = "SemanticLeft";
        }
        {
          key = "ArrowRight";
          mods = "Super";
          mode = "Vi|~Search";
          action = "SemanticRight";
        }
      ];
      mouse.hide_when_typing = true;
    };
  };
}
