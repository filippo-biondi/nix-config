{
  inputs,
  userConfig,
  ...
}: {
  imports = [
    inputs.sops-nix.darwinModules.sops
  ];

  sops = {
    age.sshKeyPaths = [ "/Users/${userConfig.username}/.ssh/id_ed25519" ];
    defaultSopsFile = ../../../../secrets/common.yaml;
    defaultSopsFormat = "yaml";

    secrets."openfortivpn/config" = {};
  };
}
