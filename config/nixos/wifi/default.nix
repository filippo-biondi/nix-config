{
  lib,
  config,
  ...
}: {
networking.networkmanager.enable = lib.mkForce false;
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      "AndroidAP15ed" = {
        pskRaw = "ext:psk_AndroidAP15ed";
      };
      "Vodafone-A62422577" = {
        pskRaw = "ext:psk_Vodafone-A62422577";
      };
      "iliadbox-0E7933" = {
        pskRaw = "ext:psk_iliadbox-0E7933";
      };
    };
    secretsFile = config.sops.secrets."wifi".path;
  };
}
