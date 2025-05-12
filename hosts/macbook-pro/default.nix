{
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    "${configFolder}/common"
    "${configFolder}/customUX"
    "${featuresFolder}/sops"
    "${featuresFolder}/core/docker"
    "${featuresFolder}/coding/openfoam"
    "${featuresFolder}/network/tailscale"
    "${featuresFolder}/network/surfshark"
    "${featuresFolder}/desktop-apps/social/whatsapp"
    "${featuresFolder}/desktop-apps/paraview"
    "${featuresFolder}/desktop-apps/misc"
    "${featuresFolder}/games/steam"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
