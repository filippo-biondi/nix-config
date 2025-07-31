{
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./sops
  ] ++ suffix_imports [
    "${configFolder}/boot/bios"
    "${configFolder}/common"
    "${configFolder}/print"
    "${featuresFolder}/core/docker"
    "${featuresFolder}/network/tailscale"
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
