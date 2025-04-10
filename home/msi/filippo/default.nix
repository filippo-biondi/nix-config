{
  nhModules,
  ...
}: {
  imports = [
    "${nhModules}/common"
    "${nhModules}/features/desktop-apps"
    "${nhModules}/features/alacritty"
    "${nhModules}/features/direnv"
    "${nhModules}/features/git"
    "${nhModules}/features/ssh"
    "${nhModules}/features/vscode"
    "${nhModules}/features/zathura"
    "${nhModules}/features/zsh"
    "${nhModules}/scripts"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
