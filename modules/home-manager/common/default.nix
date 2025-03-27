{
  outputs,
  userConfig,
  pkgs,
  ...
}: {
  imports = [
    ../programs/git
    ../programs/ssh
    ../programs/tmux
    ../programs/zsh
    ../programs/direnv
    ../scripts
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
      outputs.overlays.nvim
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Home-Manager configuration for the user's home environment
  home = {
    username = "${userConfig.name}";
    homeDirectory = "/home/${userConfig.name}";
  };

  # Ensure common packages are installed
  home.packages = with pkgs; [
      nvim-pkg
      step-cli
      nerd-fonts.jetbrains-mono
      sops
    ];

  # Set the default editor
  home.sessionVariables = {
    EDITOR = "vim";
  };
}
