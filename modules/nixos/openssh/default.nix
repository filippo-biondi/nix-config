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
      # Only the keys in nix-config, not ones added by hand to ~/.ssh/authorized_keys
      authorizedKeysInHomedir = false;
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
    # sudo accepts a signature from the forwarded SSH agent, by a key from
    # nix-config, instead of the password: the MacBook's asks for Touch ID
    security.pam.sshAgentAuth.enable = true;
  };
}
