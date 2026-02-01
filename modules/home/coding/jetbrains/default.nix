{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.coding.jetbrains;
in {
  options.ccg.coding.jetbrains.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jetbrains.pycharm-professional
      jetbrains.clion
      jetbrains.idea-ultimate
      jetbrains.webstorm
      jetbrains.gateway
    ];
  };
}
