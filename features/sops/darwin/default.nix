{
  self,
  inputs,
  userConfig,
  ...
}: {
  imports = [
    inputs.sops-nix.darwinModules.sops
  ];

  sops = {
    age.sshKeyPaths = [ "/Users/${userConfig.username}/.ssh/id_ed25519" ];
    defaultSopsFormat = "yaml";
  };
}
