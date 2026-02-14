{lib, ...}: rec {
  mkOpt = type: default: description:
    lib.mkOption {inherit type default description;};

  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt lib.types.bool;

  mkBoolOpt' = mkOpt' lib.types.bool;

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
