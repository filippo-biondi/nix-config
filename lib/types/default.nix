{lib, ...}: {
  userType = lib.types.submodule (
    {
      config,
      pkgs,
      ...
    }: {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "The login username";
        };
        fullName = lib.mkOption {
          type = lib.types.str;
        };
        email = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        sshKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        shell = lib.mkOption {
          type = lib.types.package;
          default = pkgs.bash;
        };
        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        setPassword = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };

      config = {
        fullName = lib.mkDefault config.username;
      };
    }
  );
}
