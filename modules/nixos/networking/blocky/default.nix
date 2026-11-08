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
          denylists = {
            advertising = [
              "https://adaway.org/hosts.txt"
              "https://v.firebog.net/hosts/AdguardDNS.txt"
              "https://v.firebog.net/hosts/Admiral.txt"
              "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
              "https://v.firebog.net/hosts/Easylist.txt"
              "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
              "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
            ];
            tracking = [
              "https://v.firebog.net/hosts/Easyprivacy.txt"
              "https://v.firebog.net/hosts/Prigent-Ads.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
              "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
              "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
            ];
            malicious = [
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
              "https://v.firebog.net/hosts/Prigent-Crypto.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
              "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
              "https://phishing.army/download/phishing_army_blocklist_extended.txt"
              "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
              "https://v.firebog.net/hosts/RPiList-Malware.txt"
              "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
              "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
              "https://lists.cyberhost.uk/malware.txt"
            ];
            suspicious = [
              "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
              "https://v.firebog.net/hosts/static/w3kbl.txt"
            ];
          };
          allowlists = {};
          clientGroupsBlock = {
            # 'default' group applies to all clients.
            default = [
              "advertising"
              "tracking"
              "malicious"
              "suspicious"
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
