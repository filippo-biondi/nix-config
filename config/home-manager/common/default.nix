{
  outputs,
  userConfig,
  pkgs,
  system,
  ...
}:
  let
    isDarwin = system == "aarch64-darwin" || system == "x86_64-darwin";
  in {
  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.nvim
    ] ++ (if isDarwin then [ outputs.overlays.qt_fix ] else []);

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

  # Set the default editor
  home.sessionVariables = {
    EDITOR = "vim";
  };
}
