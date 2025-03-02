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
      openfortivpn
      python3
      nerd-fonts.jetbrains-mono
    ];

  # Set the default editor
  home.sessionVariables = {
    EDITOR = "vim";
  };

  catppuccin = {
    flavor = "mocha";
    accent = "sapphire";
  };
}
