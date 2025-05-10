{
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    ./hardware-configuration.nix
    ./sops
    "${configFolder}/boot/bios"
    "${configFolder}/common"
    "${configFolder}/graphics"
    "${configFolder}/print"
    "${featuresFolder}/sops"
    "${featuresFolder}/network/openfortivpn"
    "${featuresFolder}/network/tailscale"
    "${featuresFolder}/games/factorio"
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
