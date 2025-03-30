{
  darwinModules,
  ...
}: {
  imports = [
    "${darwinModules}/common"
    "${darwinModules}/settings"
    "${darwinModules}/aerospace"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
