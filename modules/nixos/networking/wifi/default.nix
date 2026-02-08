{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.ccg.networking.wifi;
in {
  options.ccg.networking.wifi.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = lib.mkForce false;
    networking.wireless = {
      enable = true;
      userControlled = true;
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
        "FRITZ!Box-7590-XK" = {
          pskRaw = "ext:psk_FRITZ!Box-7590=XK";
        };
      };
      secretsFile = config.sops.secrets."wifi".path;
    };

    sops.secrets."wifi" = {
      sopsFile = "${inputs.secrets}/secrets/wifi.yaml";
    };
  };
}
