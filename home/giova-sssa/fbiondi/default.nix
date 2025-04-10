{
  pkgs,
  nhModules,
  ...
}: {
  imports = [
    "${nhModules}/common"
    "${nhModules}/features/alacritty"
    "${nhModules}/features/direnv"
    "${nhModules}/features/git"
    "${nhModules}/features/ssh"
    "${nhModules}/features/zsh"
    "${nhModules}/scripts"
  ];

  home.packages = with pkgs; [
    paraview
  ];

  targets.genericLinux.enable = true;

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
