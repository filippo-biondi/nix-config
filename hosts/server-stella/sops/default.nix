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
      sopsFile = "${self}/secrets/server-stella/secrets.yaml";
    };
    "openfortivpn/config" = {
      sopsFile = "${self}/secrets/openfortivpn/secrets.yaml";
      restartUnits = [ "openfortivpn.service" ];
    };
    "factorio/password" = {
      sopsFile = "${self}/secrets/factorio/secrets.yaml";
    };
  };
}
