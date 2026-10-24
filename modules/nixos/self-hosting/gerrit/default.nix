{
  inputs,
  config,
  lib,
  host,
  ...
}: let
  cfg = config.ccg.self-hosting.gerrit;
  tailscale = config.ccg.networking.tailscale;
  rootOnly = "OUTPUT -o lo -d 127.0.0.1 -p tcp --dport 8080 -m owner ! --uid-owner 0 -j REJECT";
in {
  options.ccg.self-hosting.gerrit.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = tailscale.enable;
        message = "ccg.self-hosting.gerrit is served over Tailscale: enable ccg.networking.tailscale";
      }
    ];

    services.gerrit = {
      enable = true;
      serverId = "5057e7ea-9411-4b34-a0ff-4e22463409f4";
      listenAddress = "127.0.0.1:8080";
      builtinPlugins = ["download-commands" "replication"];
      # No "+" in push: if GitHub ever diverges, replication fails instead of overwriting it
      replicationSettings = {
        gerrit.replicateOnStartup = true;
        remote.github = {
          url = "https://github.com/filippo-biondi/\${name}.git";
          push = ["refs/heads/*:refs/heads/*" "refs/tags/*:refs/tags/*"];
          projects = ["nix-config" "chezmoi-config" "claude-plugins"];
        };
      };
      settings = {
        gerrit.canonicalWebUrl = "http://${host}.${tailscale.tailnet}/";
        httpd.listenUrl = "proxy-http://127.0.0.1:8080/";
        sshd.listenAddress = "*:29418";
        # tailscale serve sets these headers for tailnet users
        auth = {
          type = "HTTP";
          httpHeader = "Tailscale-User-Login";
          httpDisplaynameHeader = "Tailscale-User-Name";
        };
      };
    };

    # The token is readable by root only; systemd passes Gerrit's dynamic user a copy
    systemd.services.gerrit = {
      serviceConfig.LoadCredential = "github-token:${config.sops.secrets."gerrit/github-token".path}";
      preStart = lib.mkAfter ''
        git config -f etc/secure.config remote.github.username x-access-token
        git config -f etc/secure.config remote.github.password "$(< "$CREDENTIALS_DIRECTORY/github-token")"
      '';
    };

    sops.secrets."gerrit/github-token".sopsFile = "${inputs.secrets}/secrets/${host}/secrets.yaml";

    systemd.services.gerrit-tailscale-serve = {
      after = ["tailscaled.service" "gerrit.socket"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = 10;
      };
      script = "${config.services.tailscale.package}/bin/tailscale serve --bg --http=80 http://127.0.0.1:8080";
    };

    networking.firewall = {
      interfaces.tailscale0.allowedTCPPorts = [29418];
      # Only tailscaled (root) may reach Gerrit: anyone else could forge the login headers
      extraCommands = "iptables -C ${rootOnly} || iptables -A ${rootOnly}";
      extraStopCommands = "iptables -D ${rootOnly} || true";
    };
  };
}
