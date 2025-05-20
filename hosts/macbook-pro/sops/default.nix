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
    "openfortivpn/config" = {
      sopsFile = "${self}/secrets/openfortivpn/secrets.yaml";
    };
  };
}
