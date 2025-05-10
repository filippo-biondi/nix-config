{
  self,
  featuresFolder,
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    "${featuresFolder}/sops"
  ];

  sops.secrets = {
    "password" = {
      sopsFile = "${self}/secrets/server-stella/secrets.yaml";
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
