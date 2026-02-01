{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.ccg.system.fonts;
in {
  options.ccg.system.fonts = {
    enable = lib.ccg.mkBoolOpt' false;
    fonts = lib.ccg.mkOpt' (lib.types.listOf lib.types.package) [];
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      # Enable icons in tooling since we have nerdfonts.
      LOG_ICONS = "true";
    };

    environment.systemPackages = lib.mkIf pkgs.stdenv.isLinux [pkgs.font-manager];

    fonts.packages = with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
      ]
      ++ cfg.fonts;
  };
}
