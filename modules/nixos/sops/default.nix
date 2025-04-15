{
  inputs,
  userConfig,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    age.sshKeyPaths = [ "/home/${userConfig.username}/.ssh/id_ed25519" ];
    defaultSopsFile = ../../../../secrets/common.yaml;
    defaultSopsFormat = "yaml";
  };
}
