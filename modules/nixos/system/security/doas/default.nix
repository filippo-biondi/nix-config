{
  config,
  lib,
  ...
}:
with lib;
with lib.ccg; let
  cfg = config.ccg.system.security.doas;
in {
  options.ccg.system.security.doas = {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    # Disable sudo
    security.sudo.enable = false;

    # Enable and configure `doas`.
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [config.user.name];
          noPass = true;
          keepEnv = true;
        }
      ];
    };

    # Add an alias to the shell for backward-compat and convenience.
    environment.shellAliases = {
      sudo = "doas";
    };
  };
}
