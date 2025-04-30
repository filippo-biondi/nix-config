{
  pkgs,
  hmModules,
  ...
}: {
  imports = [
    "${hmModules}/common"
    "${hmModules}/features/alacritty"
    "${hmModules}/features/direnv"
    "${hmModules}/features/git"
    "${hmModules}/features/ssh"
    "${hmModules}/features/zsh"
    "${hmModules}/scripts"
  ];

  home.packages = with pkgs; [
    paraview
  ];

  targets.genericLinux.enable = true;

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
