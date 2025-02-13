{ config, pkgs, ... }:

let 
  openfoam-container = pkgs.fetchgit {
    url = "https://develop.openfoam.com/packaging/containers.git";
    rev = "50f4b8c77ca610ec33d1ba7ba336157091f018d8";
    sha256 = "sha256-wv2QoHFIiV+Gsz+pwVt42ithHJ1LL1KL8pZ5PbAgDXk=";
  };

  openfoam-docker = pkgs.runCommand "openfoam-docker" {} ''
    mkdir -p $out/bin
    cp ${openfoam-container}/openfoam-docker $out/bin/openfoam-docker
    chmod +x $out/bin/openfoam-docker
  '';
in {
  home.username = "filippo";
  home.homeDirectory = "/home/filippo";

  home.file = {

  };

  home.packages = with pkgs; [
    unstable.nvim-pkg
    lshw
    discord
    zotero
    telegram-desktop
    unstable.jetbrains.gateway
    unstable.jetbrains.pycharm-professional
    openfoam-docker
    paraview
    spotify
    vlc
    obs-studio
    quickemu
    step-cli
    kicad
    openfortivpn
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

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
      window.startup_mode = "Maximized";
      keyboard.bindings = [
        { 
          key = "C"; 
          mods = "Control|Shift";
          mode = "Alt";
          action = "ReceiveChar";
        }
        { 
          key = "C"; 
          mods = "Control|Shift";
          mode = "~Alt";
          action = "Copy";
        }
        {
          key = "C";
          mods = "Control|Shift|Alt";
          action = "Copy";
        }

        {
          key = "ArrowLeft";
          mods = "Control";
          mode = "Vi|~Search";
          action = "SemanticLeft";
        }
        {
          key = "ArrowRight";
          mods = "Control";
          mode = "Vi|~Search";
          action = "SemanticRight";
        }
      ];
      mouse.hide_when_typing = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
      update = "sudo nixos-rebuild switch --flake .";
      push-update = "git push && update";
      test-update = "sudo nixos-rebuild test --flake .";
      cineca-login = "step ssh login filippo.biondi@santannapisa.it --provisioner cineca-hpc";
      vpn-login = "sudo openfortivpn fvs.santannapisa.it:443 -u fi.biondi";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initExtra = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^H" backward-kill-word

      # fg-bg toggle via c-z
      function fg-bg {
          if [[ $#BUFFER -eq 0 ]]; then
              BUFFER=fg
              zle accept-line
          else
              zle push-input
          fi
      }
      zle -N fg-bg
      bindkey '^z' fg-bg
    '';
  };

  programs.git = {
    enable = true;
    userName = "Filippo Biondi";
    userEmail = "filibiondi2000@gmail.com";
    aliases = {
      undo = "reset HEAD~1 --mixed";
    };
    extraConfig = {
      init.defaultBranch = "main";
      color.ui = "auto";
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers
      dracula-theme.theme-dracula
      vscodevim.vim
      yzhang.markdown-all-in-one
    ];
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "C-h";
  };
  
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "g100" = {
        hostname = "login.g100.cineca.it";
        user = "fbiondi0";
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
      "giovanni" = {
        hostname = "192.168.83.20";
        user = "fbiondi";
      };
    };
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
