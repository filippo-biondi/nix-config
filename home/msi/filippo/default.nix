{
  nhModules,
  ...
}: {
  imports = [
    "${nhModules}/common"
    "${nhModules}/desktop"
    "${nhModules}/services/openfortivpn"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
