{
  pkgs,
  config,
  ...
}: let
  customDir = pkgs.stdenv.mkDerivation {
    src = pkgs.fetchFromGitHub {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "a84a0332a822a78ddf3f66d0e1ed3990d4badd12";
      sha256 = "sha256-oBSs8DuPI7DgKaSSbuK5FgFwmGIVAp2B+YI9Hr1/mRw=";
    };
    name = "custom-oh-my-zsh";
    patches = [ ./fletcherm.patch ];
    installPhase = ''
      mkdir -p $out/themes
      cp themes/fletcherm.zsh-theme $out/themes/my-fletcherm.zsh-theme
    '';
  };
in {
  home.packages = with pkgs; [
    zsh-you-should-use
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "my-fletcherm";
      plugins = [
        "git"
        "docker"
        "ssh"
        "sudo"
        "systemd"
        "vi-mode"
      ];
      custom = "${customDir}";
    };

    shellAliases = {
      ll = "ls -lh";
      os-update = "sudo nixos-rebuild switch --flake .";
      hm-update = "home-manager switch --flake .";
      darwin-update = "sudo darwin-rebuild switch --flake .";
      test-os-update = "sudo nixos-rebuild test --flake .";
      cineca-login = "step ssh login filippo.biondi@santannapisa.it --provisioner cineca-hpc";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initContent = ''
      bindkey "^H" backward-kill-word

      function forward_word_alias() {
          zle forward-word
      }
      zle -N autsuggest-partial-accept forward_word_alias

      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
      ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(autsuggest-partial-accept)
      bindkey "^[[1;2F" autosuggest-accept
      bindkey "^[[1;2C" autsuggest-partial-accept


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

      export VI_MODE_SET_CURSOR=true

      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
    '';
  };
}
