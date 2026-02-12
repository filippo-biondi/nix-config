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
      jetbrains.pycharm
      jetbrains.clion
      jetbrains.idea
      jetbrains.webstorm
      jetbrains.gateway
    ];
  };
}
