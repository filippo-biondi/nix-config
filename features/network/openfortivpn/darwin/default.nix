
{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    openfortivpn
  ];

  environment.shellAliases = {
    vpn-login = "sudo openfortivpn -c ${config.sops.secrets."openfortivpn/config".path}";
  };
}
