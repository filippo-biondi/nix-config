{
  lib,
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    openfortivpn
  ];

  systemd.services.openfortivpn = {
    description = "OpenFortiVPN Service";
    after = [ "network-online.target"];
    wants = [ "network-online.target" "systemd-networkd-wait-online.service"];
    wantedBy = lib.mkForce [];

    serviceConfig = {
      ExecStart = "${pkgs.openfortivpn}/bin/openfortivpn -c ${config.sops.secrets."openfortivpn/config".path}";
      EnvironmentFile = config.sops.secrets."openfortivpn/config".path;
      User = "root";
      Type = "idle";
    };
  };
}
