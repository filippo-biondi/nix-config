{
  config,
  lib,
  ...
}:
with lib.ccg; let
  cfg = config.ccg.system.env;
in {
  options.ccg.system.env = with lib.types;
    lib.mkOption {
      type = attrsOf (oneOf [
        str
        path
        (listOf (either str path))
      ]);
      apply = lib.mapAttrs (
        _n: v:
          if lib.isList v
          then lib.concatMapStringsSep ":" toString v
          else (toString v)
      );
      default = {};
      description = "A set of environment variables to set.";
    };

  config = {
    environment = {
      sessionVariables = {
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_BIN_HOME = "$HOME/.local/bin";
        # To prevent firefox from creating ~/Desktop.
        XDG_DESKTOP_DIR = "$HOME";
      };
      variables = {
        # Make some programs "XDG" compliant.
        LESSHISTFILE = "$XDG_CACHE_HOME/less.history";
        WGETRC = "$XDG_CONFIG_HOME/wgetrc";
      };
      extraInit = lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: ''export ${n}="${v}"'') cfg);
    };
  };
}
