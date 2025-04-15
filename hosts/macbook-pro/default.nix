{
  darwinModules,
  ...
}: {
  imports = [
    "${darwinModules}/common"
    "${darwinModules}/sops"
    "${darwinModules}/features/customUX"
    "${darwinModules}/features/homebrew"
    "${darwinModules}/features/tailscale"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
