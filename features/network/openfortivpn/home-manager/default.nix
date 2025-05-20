{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    openfortivpn
  ];
  environment.shellAliases = {
    vpn-login = "sudo openfortivpn fvs.santannapisa.it:443 -u fi.biondi";
  };
}
