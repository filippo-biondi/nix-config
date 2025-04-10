{
  outputs,
  userConfig,
  pkgs,
  ...
}: {
  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.nvim
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Home-Manager configuration for the user's home environment
  home = {
    username = "${userConfig.username}";
    homeDirectory = if pkgs.stdenv.isDarwin
                    then "/Users/${userConfig.username}"
                    else "/home/${userConfig.username}";
  };

  # Ensure common packages are installed
  home.packages = with pkgs; [
      nvim-pkg
      sops
      step-cli
      nerd-fonts.jetbrains-mono
      btop
    ];

  # Set the default editor
  home.sessionVariables = {
    EDITOR = "vim";
  };
}
