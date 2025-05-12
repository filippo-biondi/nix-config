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
    "${configFolder}/graphics"
    "${configFolder}/print"
    "${featuresFolder}/network/openfortivpn"
    "${featuresFolder}/network/tailscale"
    "${featuresFolder}/games/factorio"
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
