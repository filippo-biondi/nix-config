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
        # A connection may replace a forwarded socket an earlier one left behind,
        # such as the sops key service's
        StreamLocalBindUnlink = true;
      };
    };
    programs.ssh.startAgent = true;
  };
}
