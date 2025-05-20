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
      sopsFile = "${self}/secrets/msi/secrets.yaml";
      neededForUsers = true;
    };
    "tailscale/authkey" = {
      sopsFile = "${self}/secrets/msi/secrets.yaml";
    };
    "factorio/password" = {
      sopsFile = "${self}/secrets/factorio/secrets.yaml";
    };
  };
}
