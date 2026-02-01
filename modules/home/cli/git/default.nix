{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.cli.git;
in {
  options.ccg.cli.git = {
    enable = lib.ccg.mkBoolOpt' true;
    user = lib.ccg.mkUserOpt';
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = lib.mkIf (cfg.user != null) {
          name = cfg.user.fullName;
          inherit (cfg.user) email;
        };
        init.defaultBranch = "main";
        color.ui = "auto";
      };
    };
  };
}
