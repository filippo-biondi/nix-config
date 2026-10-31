{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.cli.ssh;
in {
  options.ccg.cli.ssh = {
    enable = lib.ccg.mkBoolOpt' false;
    # Gerrit's SSH port, reached as `user` under the host name `alias`
    gerrit = {
      enable = lib.ccg.mkBoolOpt' false;
      alias = lib.ccg.mkOpt' lib.types.str "gerrit";
      user = lib.ccg.mkOpt' lib.types.str null;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable || cfg.gerrit.enable) {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };
    })
    (lib.mkIf cfg.enable {
      programs.ssh.settings = {
        "server-msi" = {
          HostName = "server-msi";
          User = "filippo";
          ForwardAgent = true;
        };
        "server-stella" = {
          HostName = "server-stella";
          User = "filippo";
          ForwardAgent = true;
        };
      };
    })
    (lib.mkIf cfg.gerrit.enable {
      programs.ssh.settings.${cfg.gerrit.alias} = {
        HostName = "server-msi";
        Port = 29418;
        User = cfg.gerrit.user;
      };
    })
  ];
}
