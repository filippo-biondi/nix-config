{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.cli.utils;
in
  with lib; {
    options.ccg.cli.utils.enable = lib.ccg.mkBoolOpt' true;

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        sops
        step-cli
        uv
        cachix
        tree
        fzf
        fd
        sshfs
        btop
      ];
    };
  }
