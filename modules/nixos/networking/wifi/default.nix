{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.ccg.networking.wifi;
  wifiProfiles = [ "hotspot" "home" "pisa_house" "berlin_house" ];
  toEnvVar = name: lib.toUpper name;
in {
  options.ccg.networking.wifi.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      ensureProfiles = {
        environmentFiles = [ config.sops.secrets."wifi".path ];

        profiles = lib.genAttrs wifiProfiles (name: {
          connection = {
            id = name;
            type = "wifi";
          };
          wifi = {
            ssid = "\$${toEnvVar name}_SSID";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "\$${toEnvVar name}_PSK";
          };
          ipv4 = { method = "auto"; };
          ipv6 = { method = "auto"; };
        });
      };
    };

    sops.secrets."wifi" = {
      sopsFile = "${inputs.secrets}/secrets/wifi.yaml";
    };
  };
}
