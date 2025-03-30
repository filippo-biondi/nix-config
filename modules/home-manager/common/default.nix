{
  outputs,
  userConfig,
  pkgs,
  ...
}: {
  imports = [
    ../programs/git
    ../programs/ssh
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
    homeDirectory = if pkgs.stdenv.isDarwin
                    then "/Users/${userConfig.name}"
                    else "/home/${userConfig.name}";
  };

  # Ensure common packages are installed
  home.packages = with pkgs; [
      nvim-pkg
      sops
      step-cli
      nerd-fonts.jetbrains-mono
      lmstudio
    ];

  # Set the default editor
  home.sessionVariables = {
    EDITOR = "vim";
  };
}
