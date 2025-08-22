{
  lib,
  configFolder,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./sops
  ] ++ suffix_imports [
    "${configFolder}/boot/raspberry"
    "${configFolder}/common"
    "${configFolder}/print"
    "${configFolder}/wifi"
    "${featuresFolder}/core/docker"
    "${featuresFolder}/network/tailscale"
    "${featuresFolder}/network/blocky"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArV7DUbiqZYLwtF5tZVQTskVPYJzaltXqZzVYJrxJwy"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5XH2x57j86zBf2eMDkEhjHBeIOuGdxWsc358WfcQT"
  ];

  services.openssh.permitRootLogin = lib.mkForce "prohibit-password";

  system.stateVersion = "24.05"; # Did you read the comment?
}
