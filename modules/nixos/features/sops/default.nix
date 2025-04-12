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
      "msi-password" = {
        sopsFile = ../../../../secrets/msi/secrets.yaml;
        neededForUsers = true;
      };
      "msi-tailscale/authkey" = {
        sopsFile = ../../../../secrets/msi/secrets.yaml;
      };
      "server-stella-password" = {
        sopsFile = ../../../../secrets/server-stella/secrets.yaml;
        neededForUsers = true;
      };
      "server-stella-tailscale/authkey" = {
        sopsFile = ../../../../secrets/server-stella/secrets.yaml;
      };
      "openfortivpn/config" = {
        restartUnits = [ "openfortivpn.service" ];
      };
    };
  };
}
