{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.system.base;
in {
  options.ccg.system.base = {
    user = lib.mkOption {
      type = lib.types.nullOr lib.ccg.userType;
      default = null;
      description = "user for home-manger config";
    };
  };

  config = lib.mkIf (cfg.user != null) {
    home = {
      username = "${cfg.user.username}";
      homeDirectory =
        if pkgs.stdenv.isDarwin
        then "/Users/${cfg.user.username}"
        else "/home/${cfg.user.username}";
    };

    # Set the default editor
    home.sessionVariables = {
      EDITOR = "vim";
    };
  };
}
