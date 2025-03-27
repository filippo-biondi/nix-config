{
  pkgs,
  config,
  ...
}: {
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
      theme = "fletcherm";
      plugins = [
        "git"
        "docker"
        "ssh"
        "sudo"
        "systemd"
        "vi-mode"
      ];
    };

    shellAliases = {
      ll = "ls -l";
      update-os = "sudo nixos-rebuild switch --flake .";
      update-hm = "home-manager switch --flake .";
      push-update = "git push && update-os && update-hm";
      test-update-os = "sudo nixos-rebuild test --flake .";
      cineca-login = "step ssh login filippo.biondi@santannapisa.it --provisioner cineca-hpc";
      vpn-login = "sudo openfortivpn fvs.santannapisa.it:443 -u fi.biondi";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initExtra = ''
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

      export export VI_MODE_SET_CURSOR=true

      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
    '';
  };
}
