{
  inputs,
  config,
  lib,
  host,
  ...
}: let
  cfg = config.ccg.networking.tailscale;
in {
  options.ccg.networking.tailscale = {
    enable = lib.ccg.mkBoolOpt' false;
    withKey = lib.ccg.mkBoolOpt' false;
    tailnet = lib.ccg.mkOpt lib.types.str "taild98f5.ts.net" "MagicDNS suffix of the tailnet";
  };
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      authKeyFile = lib.mkIf cfg.withKey "${config.sops.secrets."tailscale/authkey".path}";
    };

    sops.secrets."tailscale/authkey" = {
      sopsFile = "${inputs.secrets}/secrets/${host}/secrets.yaml";
    };
  };
}
