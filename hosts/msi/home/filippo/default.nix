{
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports =  [
    "${configFolder}/common"
  ] ++ suffix_imports [
    "${featuresFolder}/core"
    "${featuresFolder}/coding"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
