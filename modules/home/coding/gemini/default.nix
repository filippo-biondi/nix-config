{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.coding.gemini;
in {
  options.ccg.coding.gemini.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gemini-cli
    ];
  };
}
