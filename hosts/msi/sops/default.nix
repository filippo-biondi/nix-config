{
  nixosModules,
  ...
}: {
  imports = [
    "${nixosModules}/sops"
  ];

  sops.secrets = {
    "password" = {
      sopsFile = ../../../secrets/msi/secrets.yaml;
      neededForUsers = true;
    };
    "tailscale/authkey" = {
      sopsFile = ../../../secrets/msi/secrets.yaml;
    };
  };
}
