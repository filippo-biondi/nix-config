{
  inputs,
  lib,
  config,
  host,
  ...
}: let
  cfg = config.ccg;
in {
  options.ccg.users = lib.ccg.mkOpt' (lib.types.attrsOf lib.ccg.userType) {};

  config = {
    users = {
      mutableUsers = false;
      users =
        lib.mapAttrs (
          username: user: {
            isNormalUser = true;
            description = user.fullName;
            inherit (user) shell;
            openssh.authorizedKeys.keys = user.sshKeys;
            inherit (user) extraGroups;
            hashedPasswordFile =
              lib.mkIf user.setPassword config.sops.secrets."${username}/passwordHash".path;
          }
        )
        cfg.users;
    };

    sops.secrets = lib.mapAttrs' (username: _: {
      name = "${username}/passwordHash";
      value = {
        sopsFile = "${inputs.self}/secrets/${host}/secrets.yaml";
        neededForUsers = true;
      };
    }) (lib.filterAttrs (_: user: user.setPassword) cfg.users);
  };
}
