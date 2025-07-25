{
  pkgs,
  ...
}: {
  services.yabai = {
    enable = true;
    package = pkgs.nightly.yabai;
    enableScriptingAddition = true;

    config = {
      layout                     = "bsp";
      focus_follows_mouse        = "off";
      mouse_follows_focus        = "off";
      window_origin_display      = "focused";
      window_opacity             = "on";
      active_window_opacity      = "1.0";
      normal_window_opacity      = "0.90";
      window_animation_duration  = "0.15";
      window_animation_easing    = "ease_out_expo";
      window_shadow              = "on";
      split_ratio                = "0.50";
      mouse_modifier             = "alt";
      mouse_action1              = "move";
      mouse_action2              = "resize";
      mouse_drop_action          = "swap";
      split_type                 = "auto";
      top_padding                = "0";
      bottom_padding             = "0";
      left_padding               = "0";
      right_padding              = "0";
      window_gap                 = "5";
      auto_balance               = "off";
      debug_output               = "on";
    };

    extraConfig = ''
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

      for idx in {1..7}; do
        if ! yabai -m query --spaces | jq '.[].index' | grep -q "^$idx\$"; then
          yabai -m space --create
        fi
      done

      yabai -m space 1 --label Term
      yabai -m space 2 --label Web
      yabai -m space 3 --label Mail
      yabai -m space 4 --label Chat
      yabai -m space 5 --label Media
      yabai -m space 6 --label Games

      yabai -m rule --add app="^Alacritty$"     space=^Term
      yabai -m rule --add app="^Safari$"        space=^Web
      yabai -m rule --add app="^Firefox$"       space=^Web
      yabai -m rule --add app="^Mail$"          space=^Mail
      yabai -m rule --add app="^Telegram$"      space=^Chat
      yabai -m rule --add app="^Discord$"       space=^Chat
      yabai -m rule --add app="^Spotify$"       space=^Media
      yabai -m rule --add app="^factorio$"      space=^Games
      yabai -m rule --add app="^Steam$"         space=^Games

      # apps to float (ignore)
      yabai -m rule --add app="^System Settings$"  manage=off
      yabai -m rule --add app="^Karabiner"         manage=off
      yabai -m rule --add app="^Calculator$"       manage=off
      yabai -m rule --add app="^Bitwarden$"       manage=off
    '';
  };

  services.skhd = {
    enable = true;
    skhdConfig = let
      mod  = "alt";
      mod2 = "alt + ctrl";
      mod3 = "alt + shift";
      mod4 = "alt + cmd";
      mod5 = "alt + cmd + shift";
      mod6 = "alt + ctrl + shift";
    in ''
      # focus windows
      ${mod} - left : yabai -m window --focus west
      ${mod} - down : yabai -m window --focus south
      ${mod} - up : yabai -m window --focus north
      ${mod} - right : yabai -m window --focus east
      ${mod} - tab : yabai -m display --focus recent

      # swap windows
      ${mod4} - left : yabai -m window --swap west
      ${mod4} - down : yabai -m window --swap south
      ${mod4} - up : yabai -m window --swap north
      ${mod4} - right : yabai -m window --swap east

      # warp windows
      ${mod5} - left : yabai -m window --warp west
      ${mod5} - down : yabai -m window --warp south
      ${mod5} - up : yabai -m window --warp north
      ${mod5} - right : yabai -m window --warp east

      # move between spaces
      ${mod2} - left  : yabai -m space --focus prev || yabai -m space --focus last
      ${mod2} - right : yabai -m space --focus next || yabai -m space --focus first
      ${mod2} - tab   : yabai -m space --focus recent
      ${mod2} - t : yabai -m space --focus Term
      ${mod2} - w : yabai -m space --focus Web
      ${mod2} - m : yabai -m space --focus Mail
      ${mod2} - c : yabai -m space --focus Chat
      ${mod2} - p : yabai -m space --focus Media
      ${mod2} - g : yabai -m space --focus Games

      # move windows between spaces
      ${mod3} - left  : yabai -m window --space prev --focus
      ${mod3} - right : yabai -m window --space next --focus
      ${mod3} - tab   : yabai -m window --display recent --focus
      ${mod3} - t : yabai -m window --space Term --focus
      ${mod3} - w : yabai -m window --space Web --focus
      ${mod3} - m : yabai -m window --space Mail --focus
      ${mod3} - c : yabai -m window --space Chat --focus
      ${mod3} - p : yabai -m window --space Media --focus
      ${mod3} - g : yabai -m window --space Games --focus

      # move spaces
      ${mod6} - left : yabai -m space --move prev
      ${mod6} - right : yabai -m space --move next
      ${mod6} - tab : yabai -m space --display recent

      # miscellaneous
      ${mod} - f : yabai -m window --toggle zoom-fullscreen
      ${mod} - t : yabai -m window --toggle float && yabai -m window --grid 4:4:1:1:2:2
      ${mod} - b : yabai -m space --balance
      ${mod} - r : yabai -m space --rotate 90
      ${mod} - 0x2C : yabai -m window --toggle split
      ${mod} - s : yabai -m window --toggle sticky
      ${mod} - n : yabai -m space --create
      ${mod} - d : yabai -m space --destroy
      ${mod} - o : yabai -m config --space opacity toggle
    '';
  };
}
