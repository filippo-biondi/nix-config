{ ... }: {
  services.aerospace = {
    enable = true;
    settings = {
      automatically-unhide-macos-hidden-apps = true;

      mode.main.binding = {
        alt-left = "focus left";
        alt-down = "focus down";
        alt-up = "focus up";
        alt-right = "focus right";

        alt-shift-left = "move left";
        alt-shift-down = "move down";
        alt-shift-up = "move up";
        alt-shift-right = "move right";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-a = "workspace A";
        alt-b = "workspace B";
        alt-c = "workspace C";
        alt-d = "workspace D";
        alt-e = "workspace E";
        alt-f = "workspace F";
        alt-g = "workspace G";
        alt-i = "workspace I";
        alt-m = "workspace M";
        alt-n = "workspace N";
        alt-o = "workspace O";
        alt-p = "workspace P";
        alt-q = "workspace Q";
        alt-r = "workspace R";
        alt-s = "workspace S";
        alt-t = "workspace T";
        alt-u = "workspace U";
        alt-v = "workspace V";
        alt-w = "workspace W";
        alt-x = "workspace X";
        alt-y = "workspace Y";
        alt-z = "workspace Z";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-a = "move-node-to-workspace A";
        alt-shift-b = "move-node-to-workspace B";
        alt-shift-c = "move-node-to-workspace C";
        alt-shift-d = "move-node-to-workspace D";
        alt-shift-e = "move-node-to-workspace E";
        alt-shift-f = "move-node-to-workspace F";
        alt-shift-g = "move-node-to-workspace G";
        alt-shift-i = "move-node-to-workspace I";
        alt-shift-m = "move-node-to-workspace M";
        alt-shift-n = "move-node-to-workspace N";
        alt-shift-o = "move-node-to-workspace O";
        alt-shift-p = "move-node-to-workspace P";
        alt-shift-q = "move-node-to-workspace Q";
        alt-shift-r = "move-node-to-workspace R";
        alt-shift-s = "move-node-to-workspace S";
        alt-shift-t = "move-node-to-workspace T";
        alt-shift-u = "move-node-to-workspace U";
        alt-shift-v = "move-node-to-workspace V";
        alt-shift-w = "move-node-to-workspace W";
        alt-shift-x = "move-node-to-workspace X";
        alt-shift-y = "move-node-to-workspace Y";
        alt-shift-z = "move-node-to-workspace Z";

        alt-cmd-shift-1 = ["move-node-to-workspace 1" "workspace 1"];
        alt-cmd-shift-2 = ["move-node-to-workspace 2" "workspace 2"];
        alt-cmd-shift-3 = ["move-node-to-workspace 3" "workspace 3"];
        alt-cmd-shift-4 = ["move-node-to-workspace 4" "workspace 4"];
        alt-cmd-shift-5 = ["move-node-to-workspace 5" "workspace 5"];
        alt-cmd-shift-6 = ["move-node-to-workspace 6" "workspace 6"];
        alt-cmd-shift-7 = ["move-node-to-workspace 7" "workspace 7"];
        alt-cmd-shift-8 = ["move-node-to-workspace 8" "workspace 8"];
        alt-cmd-shift-9 = ["move-node-to-workspace 9" "workspace 9"];
        alt-cmd-shift-a = ["move-node-to-workspace A" "workspace A"];
        alt-cmd-shift-b = ["move-node-to-workspace B" "workspace B"];
        alt-cmd-shift-c = ["move-node-to-workspace C" "workspace C"];
        alt-cmd-shift-d = ["move-node-to-workspace D" "workspace D"];
        alt-cmd-shift-e = ["move-node-to-workspace E" "workspace E"];
        alt-cmd-shift-f = ["move-node-to-workspace F" "workspace F"];
        alt-cmd-shift-g = ["move-node-to-workspace G" "workspace G"];
        alt-cmd-shift-i = ["move-node-to-workspace I" "workspace I"];
        alt-cmd-shift-m = ["move-node-to-workspace M" "workspace M"];
        alt-cmd-shift-n = ["move-node-to-workspace N" "workspace N"];
        alt-cmd-shift-o = ["move-node-to-workspace O" "workspace O"];
        alt-cmd-shift-p = ["move-node-to-workspace P" "workspace P"];
        alt-cmd-shift-q = ["move-node-to-workspace Q" "workspace Q"];
        alt-cmd-shift-r = ["move-node-to-workspace R" "workspace R"];
        alt-cmd-shift-s = ["move-node-to-workspace S" "workspace S"];
        alt-cmd-shift-t = ["move-node-to-workspace T" "workspace T"];
        alt-cmd-shift-u = ["move-node-to-workspace U" "workspace U"];
        alt-cmd-shift-v = ["move-node-to-workspace V" "workspace V"];
        alt-cmd-shift-w = ["move-node-to-workspace W" "workspace W"];
        alt-cmd-shift-x = ["move-node-to-workspace X" "workspace X"];
        alt-cmd-shift-y = ["move-node-to-workspace Y" "workspace Y"];
        alt-cmd-shift-z = ["move-node-to-workspace Z" "workspace Z"];

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        alt-slash = "layout tiles horizontal vertical";
        alt-period = "layout accordion horizontal vertical";
      };
    };
  };
}
