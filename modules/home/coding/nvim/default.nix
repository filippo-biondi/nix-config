{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.coding.nvim;
in {
  options.ccg.coding.nvim.enable = lib.ccg.mkBoolOpt' true;

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nvim-pkg
    ];
  };
}
