{ ... }: {
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh.oh-my-zsh.plugins = [ "direnv" ];
  };
}
