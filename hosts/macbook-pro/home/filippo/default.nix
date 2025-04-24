{
  hmModules,
  ...
}: {
  imports = [
    "${hmModules}/common"
    "${hmModules}/features/desktop-apps"
    "${hmModules}/features/alacritty"
    "${hmModules}/features/direnv"
    "${hmModules}/features/git"
    "${hmModules}/features/ssh"
    "${hmModules}/features/vscode"
    "${hmModules}/features/zathura"
    "${hmModules}/features/zsh"
    "${hmModules}/scripts"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}

