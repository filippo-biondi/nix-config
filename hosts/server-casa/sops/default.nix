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
      sopsFile = "${self}/secrets/server-casa/secrets.yaml";
      neededForUsers = true;
    };
    "tailscale/authkey" = {
      sopsFile = "${self}/secrets/server-casa/secrets.yaml";
    };
  };
}
