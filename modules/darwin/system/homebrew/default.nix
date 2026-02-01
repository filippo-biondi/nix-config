{
  config,
  lib,
  ...
}: let
  cfg = config.ccg.system.homebrew;
in {
  options.ccg.system.homebrew = {
    enable = lib.ccg.mkBoolOpt' false;
  };

  config = lib.mkIf cfg.enable {
    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = config.system.primaryUser;
    };

    homebrew = {
      enable = true;
      global.autoUpdate = false;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };
    };
  };
}
