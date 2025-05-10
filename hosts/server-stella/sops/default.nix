{
  nixosModules,
  ...
}: {
  imports = [
    "${nixosModules}/sops"
  ];

  sops.secrets = {
    "password" = {
      sopsFile = ../../../secrets/server-stella/secrets.yaml;
      neededForUsers = true;
    };
    "tailscale/authkey" = {
      sopsFile = ../../../secrets/server-stella/secrets.yaml;
    };
    "openfortivpn/config" = {
      restartUnits = [ "openfortivpn.service" ];
    };
    "factorio/password" = {
      sopsFile = ../../../secrets/server-stella/secrets.yaml;
    };
  };
}
