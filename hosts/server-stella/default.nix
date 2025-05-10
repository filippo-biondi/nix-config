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
    "${configFolder}/nixos/boot/bios"
    "${configFolder}/nixos/common"
    "${configFolder}/nixos/graphics"
    "${configFolder}/nixos/print"
    "${featuresFolder}/network/openfortivpn"
    "${featuresFolder}/network/tailscale"
    "${featuresFolder}/games/factorio"
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
