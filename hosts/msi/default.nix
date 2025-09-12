{
  config,
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./sops
  ] ++ suffix_imports [
    "${configFolder}/boot/uefi"
    "${configFolder}/common"
    "${configFolder}/graphics"
    "${configFolder}/nvidia"
    "${configFolder}/print"
    "${configFolder}/wifi"
    "${featuresFolder}/core/docker"
    "${featuresFolder}/network/tailscale"
    "${featuresFolder}/self-hosting/immich"
    "${featuresFolder}/self-hosting/interpelli-bot"
    "${featuresFolder}/games/factorio"
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
