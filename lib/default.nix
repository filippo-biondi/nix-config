{lib, ...}:
with lib; rec {
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;

  mkBoolOpt' = mkOpt' types.bool;

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  mkUserOpt = description:
    lib.mkOption {
      inherit description;
      type = lib.types.nullOr lib.ccg.userType;
      default = null;
    };

  mkUserOpt' = mkUserOpt null;
}
