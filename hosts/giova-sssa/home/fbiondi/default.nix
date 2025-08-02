{
  pkgs,
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    "${configFolder}/common"
    "${featuresFolder}/core"
    "${featuresFolder}/coding"
  ];

  targets.genericLinux.enable = true;

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
