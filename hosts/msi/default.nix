{
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    ./hardware-configuration.nix
    ./sops
    "${configFolder}/boot/uefi"
    "${configFolder}/common"
    "${configFolder}/graphics"
    "${configFolder}/nvidia"
    "${configFolder}/print"
    "${featuresFolder}/network/openfortivpn"
    "${featuresFolder}/network/tailscale"
    "${featuresFolder}/self-hosting/immich"
    "${featuresFolder}/games/factorio"
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
