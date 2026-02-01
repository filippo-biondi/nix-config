{
  lib,
  config,
  ...
}: let
  cfg = config.ccg;
in {
  options.ccg.users = lib.ccg.mkOpt' (lib.types.attrsOf lib.ccg.userType) {};

  config = {
    users.users =
      lib.mapAttrs (username: user: {
        home = "/Users/${username}";
        createHome = true;
        description = user.fullName;
        inherit (user) shell;
        openssh.authorizedKeys.keys = user.sshKeys;
      }) cfg.users;
  };
}
