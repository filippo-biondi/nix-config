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
          "https://dns.digitalcourage.de/dns-query"
          "https://dns.adguard-dns.com/dns-query"
        ];

        # Networking configuration
        ports = {
          dns = 53;
          http = 4000;
        };

        # Blocking configuration
        blocking = {
          blackLists = {
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
              "https://urlhaus.abuse.ch/downloads/hostfile/"
              "https://lists.cyberhost.uk/malware.txt"
            ];
            suspicious = [
              "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
              "https://v.firebog.net/hosts/static/w3kbl.txt"
            ];
          };
          whiteLists = {};
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
          refreshPeriod = "1440m"; # Refresh lists every 24 hours
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

        # Logging and timezone
        logLevel = "info";
        logFormat = "text";
      };
    };

    # Ensure your firewall allows DNS and web interface traffic.
    networking.firewall.allowedTCPPorts = [
      53
      4000
    ];
    networking.firewall.allowedUDPPorts = [53];
  };
}
