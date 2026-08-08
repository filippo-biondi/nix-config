{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.cli.ssh;
in {
  options.ccg.cli.ssh.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
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
    };
  };
}
