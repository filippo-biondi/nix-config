{
  config,
  lib,
  ...
}: let
  cfg = config.ccg.shells.nushell; # Assuming you rename your option
in {
  options.ccg.shells.nushell = {
    enable = lib.ccg.mkBoolOpt' false;
  };
  # Nushell doesn't need "you-should-use" because it has
  # incredible fuzzy completion/suggestions built-in.
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      enable = true;

      # Aliases are much cleaner in Nu
      shellAliases = {
        ll = "ls -l"; # Nu's ls is already 'human-readable' by default
        os-update = "sudo nixos-rebuild switch --flake .";
        hm-update = "home-manager switch --flake .";
        darwin-update = "sudo darwin-rebuild switch --flake .";
        test-os-update = "sudo nixos-rebuild test --flake .";
      };

      # This replaces your initContent and keybindings
      extraConfig = ''
        $env.config = {
          show_banner: false,
          edit_mode: "vi", # Replaces VI_MODE_SET_CURSOR

          # Keybindings for your specific workflows
          keybindings: [
            {
              name: backward_kill_word
              modifier: control
              keycode: char_h
              mode: [emacs, vi_insert, vi_normal]
              event: { edit: BackspaceWord }
            }
          ]
        }
      '';
    };
  };
}
