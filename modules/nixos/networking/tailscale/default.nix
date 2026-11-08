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
    # Offered to the tailnet's devices, which send their traffic through this
    # host only while they choose it as their exit node
    exitNode = lib.ccg.mkBoolOpt' false;
    # Local networks, such as 192.168.178.0/24, reachable from the tailnet through this host
    routes = lib.ccg.mkOpt' (lib.types.listOf lib.types.str) [];
  };
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      # Without its UDP port, peers can only meet through Tailscale's slow relays
      openFirewall = true;
      authKeyFile = lib.mkIf cfg.withKey "${config.sops.secrets."tailscale/authkey".path}";
      # Forwarding traffic for others needs IP forwarding
      useRoutingFeatures = lib.mkIf (cfg.exitNode || cfg.routes != []) "server";
      # Applied on every start, and always both: turning one off withdraws it
      extraSetFlags = [
        "--advertise-exit-node=${lib.boolToString cfg.exitNode}"
        "--advertise-routes=${lib.concatStringsSep "," cfg.routes}"
      ];
    };

    # nixpkgs only runs tailscale set when tailscaled starts. Started with the
    # system and kept active, a switch runs it, and runs it again when the
    # flags change
    systemd.services.tailscaled-set = {
      wantedBy = ["multi-user.target"];
      serviceConfig.RemainAfterExit = true;
    };

    sops.secrets."tailscale/authkey" = {
      sopsFile = "${inputs.secrets}/secrets/${host}/secrets.yaml";
    };
  };
}
