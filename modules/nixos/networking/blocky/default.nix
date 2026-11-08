{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.networking.blocky;
in {
  options.ccg.networking.blocky.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        upstreams.groups.default = [
          "https://dns.quad9.net/dns-query"
          "https://dns.adguard-dns.com/dns-query"
        ];

        # By IP: through the system's resolver, which can be this very Blocky
        # once the tailnet uses it, the upstreams' names would never resolve
        bootstrapDns = [
          {
            upstream = "https://dns.quad9.net/dns-query";
            ips = ["9.9.9.9" "149.112.112.112"];
          }
        ];

        # Networking configuration
        ports = {
          dns = 53;
          http = 4000;
        };

        # Blocking configuration
        blocking = {
          # HaGeZi's lists, maintained daily and curated against false positives
          denylists = {
            # Ads, tracking and telemetry
            ads = ["https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.txt"];
            # Malware, phishing, scams and cryptojacking, from threat intelligence feeds
            threats = ["https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/tif.txt"];
          };
          allowlists = {};
          clientGroupsBlock = {
            # 'default' group applies to all clients.
            default = [
              "ads"
              "threats"
            ];
          };
          blockType = "zeroIp";
          loading = {
            refreshPeriod = "24h";
            # Answer right away and load the lists meanwhile, even if one is unreachable
            strategy = "fast";
          };
        };

        # metrics configuration
        prometheus = {
          enable = true;
          path = "/metrics";
        };

        # Caching configuration
        caching = {
          minTime = "2m";
          maxTime = "15m";
        };

        log = {
          level = "info";
          format = "text";
        };
        # Otherwise every query is logged to the journal
        queryLog.type = "none";
      };
    };

    # DNS for the local network. The HTTP API and metrics on port 4000 stay
    # reachable from the tailnet only
    networking.firewall.allowedTCPPorts = [53];
    networking.firewall.allowedUDPPorts = [53];
  };
}
