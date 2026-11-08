{
  inputs,
  config,
  lib,
  pkgs,
  host,
  ...
}: let
  cfg = config.ccg.self-hosting.gerrit;
  tailscale = config.ccg.networking.tailscale;
  rootOnly = "OUTPUT -o lo -d 127.0.0.1 -p tcp --dport 8080 -m owner ! --uid-owner 0 -j REJECT";

  github = "https://github.com/filippo-biondi";

  applyProjects = pkgs.writeShellApplication {
    name = "gerrit-apply-projects";
    runtimeInputs = [pkgs.coreutils pkgs.git pkgs.gnugrep pkgs.jq];
    text = builtins.readFile ./apply-projects.sh;
  };
  projectsFile = pkgs.writeText "gerrit-projects.json" (builtins.toJSON cfg.projects);

  projectType = lib.types.submodule {
    options = {
      description = lib.ccg.mkOpt' (lib.types.nullOr lib.types.str) null;
      # Pushed to GitHub, and imported from there while the project has no branches
      mirror = lib.ccg.mkBoolOpt' false;
      # Keys of project.config by section, named as git config does, such as
      # "access.refs/heads/*". A key removed from here stays in the project
      settings = lib.ccg.mkOpt' (lib.types.attrsOf (lib.types.attrsOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str)))) {};
      # UUIDs of the groups named in settings, as Gerrit needs them in the groups file
      groups = lib.ccg.mkOpt' (lib.types.attrsOf lib.types.str) {};
    };
  };
in {
  options.ccg.self-hosting.gerrit = {
    enable = lib.ccg.mkBoolOpt' false;
    # Only what is declared here is managed: anything else in a project's
    # configuration, such as permissions set in the web UI, is left alone
    projects = lib.ccg.mkOpt' (lib.types.attrsOf projectType) {};
  };

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
          url = "${github}/\${name}.git";
          push = ["refs/heads/*:refs/heads/*" "refs/tags/*:refs/tags/*"];
          projects = lib.attrNames (lib.filterAttrs (_: project: project.mirror) cfg.projects);
        };
      };
      settings = {
        gerrit.canonicalWebUrl = "https://${host}.${tailscale.tailnet}/";
        httpd.listenUrl = "proxy-https://127.0.0.1:8080/";
        sshd.listenAddress = "*:29418";
        # No mail server here: every notification would fail
        sendemail.enable = false;
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
        ${lib.getExe applyProjects} ${projectsFile} ${github}
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
      script = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=443 http://127.0.0.1:8080";
    };

    networking.firewall = {
      interfaces.tailscale0.allowedTCPPorts = [29418];
      # Only tailscaled (root) may reach Gerrit: anyone else could forge the login headers
      extraCommands = "iptables -C ${rootOnly} || iptables -A ${rootOnly}";
      extraStopCommands = "iptables -D ${rootOnly} || true";
    };
  };
}
