{
  config,
  lib,
  ...
}: let
  cfg = config.ccg.self-hosting.home-assistant;
  hass = config.services.home-assistant;
in {
  options.ccg.self-hosting.home-assistant.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      # Added from the UI: Matter for tado and the Thread switches, the projector, the vacuum.
      # met and radio_browser are what onboarding sets up
      extraComponents = ["matter" "androidtv_remote" "roborock" "met" "radio_browser"];
      config = {
        default_config = {};
        # Reached through tailscale serve only
        http = {
          server_host = ["127.0.0.1" "::1"];
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1" "::1"];
        };
        # So that automations, scenes and scripts made in the UI can be saved
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
      };
    };
    systemd.tmpfiles.rules = map (file: "f ${hass.configDir}/${file} 0644 hass hass") ["automations.yaml" "scenes.yaml" "scripts.yaml"];

    # Home Assistant's Matter integration connects to it at ws://localhost:5580/ws.
    # It reaches Thread devices through the Nest Hub, which routes the Thread network
    services.matterjs-server.enable = true;
    # Matter traffic from the devices, to the controller
    networking.firewall.allowedUDPPorts = [5540];

    # https://<host>.<tailnet>:8123, with a certificate from Tailscale
    systemd.services.home-assistant-tailscale-serve = {
      after = ["tailscaled.service" "home-assistant.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = 10;
      };
      script = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=8123 http://127.0.0.1:8123";
    };
  };
}
