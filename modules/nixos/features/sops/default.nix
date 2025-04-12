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

    secrets = {
      msi = {
        "password" = {
          sopsFile = ../../../../secrets/msi/secrets.yaml;
          neededForUsers = true;
        };
        "tailscale/authkey" = {
          sopsFile = ../../../../secrets/msi/secrets.yaml;
        };
      };
      "openfortivpn/config" = {
        restartUnits = [ "openfortivpn.service" ];
      };
    };
  };
}
