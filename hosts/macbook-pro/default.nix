{
  darwinModules,
  ...
}: {
  imports = [
    "${darwinModules}/common"
    "${darwinModules}/settings"
    "${darwinModules}/sops"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
