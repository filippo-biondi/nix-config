{
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    "${configFolder}/home-manager/common"
    "${featuresFolder}/core"
    "${featuresFolder}/desktop-apps"
    "${featuresFolder}/coding"
    "${featuresFolder}/coding/jetbrains"
    "${featuresFolder}/network/openfortivpn"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}

