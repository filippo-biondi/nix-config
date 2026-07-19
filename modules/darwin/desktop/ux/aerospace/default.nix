{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.ccg.desktop.ux.aerospace;
in {
  options.ccg.desktop.ux.aerospace.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.aerospace = {
      enable = true;
      package = pkgs.nightly.aerospace;
      settings = {
        mode.main.binding = {
          cmd-alt-left = "focus left --boundaries-action wrap-around-the-workspace";
          cmd-alt-down = "focus down --boundaries-action wrap-around-the-workspace";
          cmd-alt-up = "focus up --boundaries-action wrap-around-the-workspace";
          cmd-alt-right = "focus right --boundaries-action wrap-around-the-workspace";

          cmd-shift-alt-left = "move left";
          cmd-shift-alt-down = "move down";
          cmd-shift-alt-up = "move up";
          cmd-shift-alt-right = "move right";

          cmd-alt-1 = "workspace 1";
          cmd-alt-2 = "workspace 2";
          cmd-alt-3 = "workspace 3";
          cmd-alt-4 = "workspace 4";
          cmd-alt-5 = "workspace 5";
          cmd-alt-6 = "workspace 6";
          cmd-alt-7 = "workspace 7";
          cmd-alt-8 = "workspace 8";
          cmd-alt-9 = "workspace 9";
          cmd-alt-a = "workspace A";
          cmd-alt-b = "workspace B";
          cmd-alt-c = "workspace C";
          cmd-alt-d = "workspace D";
          cmd-alt-e = "workspace E";
          cmd-alt-f = "workspace F";
          cmd-alt-g = "workspace G";
          cmd-alt-h = "workspace H";
          cmd-alt-i = "workspace I";
          cmd-alt-j = "workspace J";
          cmd-alt-k = "workspace K";
          cmd-alt-l = "workspace L";
          cmd-alt-m = "workspace M";
          cmd-alt-n = "workspace N";
          cmd-alt-o = "workspace O";
          cmd-alt-p = "workspace P";
          cmd-alt-q = "workspace Q";
          cmd-alt-r = "workspace R";
          cmd-alt-s = "workspace S";
          cmd-alt-t = "workspace T";
          cmd-alt-u = "workspace U";
          cmd-alt-v = "workspace V";
          cmd-alt-w = "workspace W";
          cmd-alt-x = "workspace X";
          cmd-alt-y = "workspace Y";
          cmd-alt-z = "workspace Z";

          cmd-alt-shift-1 = "move-node-to-workspace 1 --focus-follows-window";
          cmd-alt-shift-2 = "move-node-to-workspace 2 --focus-follows-window";
          cmd-alt-shift-3 = "move-node-to-workspace 3 --focus-follows-window";
          cmd-alt-shift-4 = "move-node-to-workspace 4 --focus-follows-window";
          cmd-alt-shift-5 = "move-node-to-workspace 5 --focus-follows-window";
          cmd-alt-shift-6 = "move-node-to-workspace 6 --focus-follows-window";
          cmd-alt-shift-7 = "move-node-to-workspace 7 --focus-follows-window";
          cmd-alt-shift-8 = "move-node-to-workspace 8 --focus-follows-window";
          cmd-alt-shift-9 = "move-node-to-workspace 9 --focus-follows-window";
          cmd-alt-shift-a = "move-node-to-workspace A --focus-follows-window";
          cmd-alt-shift-b = "move-node-to-workspace B --focus-follows-window";
          cmd-alt-shift-c = "move-node-to-workspace C --focus-follows-window";
          cmd-alt-shift-d = "move-node-to-workspace D --focus-follows-window";
          cmd-alt-shift-e = "move-node-to-workspace E --focus-follows-window";
          cmd-alt-shift-f = "move-node-to-workspace F --focus-follows-window";
          cmd-alt-shift-g = "move-node-to-workspace G --focus-follows-window";
          cmd-alt-shift-h = "move-node-to-workspace H --focus-follows-window";
          cmd-alt-shift-i = "move-node-to-workspace I --focus-follows-window";
          cmd-alt-shift-j = "move-node-to-workspace J --focus-follows-window";
          cmd-alt-shift-k = "move-node-to-workspace K --focus-follows-window";
          cmd-alt-shift-l = "move-node-to-workspace L --focus-follows-window";
          cmd-alt-shift-m = "move-node-to-workspace M --focus-follows-window";
          cmd-alt-shift-n = "move-node-to-workspace N --focus-follows-window";
          cmd-alt-shift-o = "move-node-to-workspace O --focus-follows-window";
          cmd-alt-shift-p = "move-node-to-workspace P --focus-follows-window";
          cmd-alt-shift-q = "move-node-to-workspace Q --focus-follows-window";
          cmd-alt-shift-r = "move-node-to-workspace R --focus-follows-window";
          cmd-alt-shift-s = "move-node-to-workspace S --focus-follows-window";
          cmd-alt-shift-t = "move-node-to-workspace T --focus-follows-window";
          cmd-alt-shift-u = "move-node-to-workspace U --focus-follows-window";
          cmd-alt-shift-v = "move-node-to-workspace V --focus-follows-window";
          cmd-alt-shift-w = "move-node-to-workspace W --focus-follows-window";
          cmd-alt-shift-x = "move-node-to-workspace X --focus-follows-window";
          cmd-alt-shift-y = "move-node-to-workspace Y --focus-follows-window";
          cmd-alt-shift-z = "move-node-to-workspace Z --focus-follows-window";

          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
          cmd-alt-space = "focus-monitor --wrap-around next";

          cmd-alt-slash = "layout tiling";
          cmd-alt-period = "layout accordion";
        };
      };
    };
  };
}
