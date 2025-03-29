{
  darwinModules,
  ...
}: {
  import = [
    "${darwinModules}/common"
    "${darwinModules}/settings"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
