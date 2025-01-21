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

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    kitty
    lshw
    discord
    zotero
    telegram-desktop
    unstable.jetbrains.gateway
    unstable.jetbrains.pycharm-professional
    openfoam-docker
    vlc
    obs-studio
    doxygen
    quickemu
    step-cli
    kicad
  ];

  home.file = {
    #".local/bin/openfoam-docker" = {
    #  source = "${openfoam-container}/openfoam-docker";
    #  executable = true;
    #};
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake .";
      cineca-login = "step ssh login filippo.biondi@santannapisa.it --provisioner cineca-hpc";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initExtra = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
    '';
  };

#  wayland.windowManager.hyprland = {
#    enable = true;
#    # set the flake package
#    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
#  };

  programs.git = {
    enable = true;
    userName = "Filippo Biondi";
    userEmail = "filibiondi2000@gmail.com";
    aliases = {
      undo = "reset HEAD~1 --mixed";
    };
    extraConfig = {
      color = {
        ui = "auto";
      };
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
    };
  };

  programs.home-manager.enable = true;
}
