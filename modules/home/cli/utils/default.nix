{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.cli.utils;
in {
  options.ccg.cli.utils.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      age-plugin-fido2-hmac
      ccg.sys
      tree
      btop
    ];
  };
}
