{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.openssh;
in {
  options.ccg.openssh.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    programs.ssh.startAgent = true;
  };
}
