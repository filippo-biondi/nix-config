{ config, pkgs, ... }:
let
  configFiles = pkgs.stdenv.mkDerivation {
    name = "surfshark-config";
    src = pkgs.fetchurl {
      url = "https://my.surfshark.com/vpn/api/v1/server/configurations";
      sha256 = "sha256-0WhkkVi6mbhfzBtyCBJD6PjbnoCN+bWMDXW1sTes2R8=";
    };
    phases = [ "installPhase" ];
    buildInputs = [ pkgs.unzip pkgs.rename ];
    installPhase = ''
      unzip $src 
      find . -type f ! -name '*_udp.ovpn' -delete
      rename 's/prod.surfshark.com_udp.//' *
      mkdir -p $out
      mv * $out
    '';
  };

  getConfig = filePath: {
    name = "${builtins.substring 0 (builtins.stringLength filePath - 5) filePath}";
    value = { config = '' config ${configFiles}/${filePath} ''; autoStart = false; };
  };
  openVPNConfigs = map getConfig (builtins.attrNames (builtins.readDir configFiles));
in
{
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  services.openvpn.servers = builtins.listToAttrs openVPNConfigs;
}
