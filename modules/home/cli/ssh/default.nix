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
      matchBlocks = {
        "server-msi" = {
          hostname = "server-msi";
          user = "filippo";
          forwardAgent = true;
        };
        "server-stella" = {
          hostname = "server-stella";
          user = "filippo";
          forwardAgent = true;
        };
      };
    };
  };
}
