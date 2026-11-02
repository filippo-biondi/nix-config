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
        lib.mapAttrs (username: user: {
          isNormalUser = true;
          description = user.fullName;
          inherit (user) shell;
          openssh.authorizedKeys.keys = user.sshKeys;
          inherit (user) extraGroups;
          inherit (user) linger;
          hashedPasswordFile = lib.mkIf user.setPassword config.sops.secrets."${username}/passwordHash".path;
        })
        cfg.users;
    };

    # Snowfall puts every user with a home in wheel: extraGroups decides instead
    snowfallorg.users = lib.mapAttrs (_: _: {admin = false;}) cfg.users;

    sops.secrets =
      lib.mapAttrs' (username: _: {
        name = "${username}/passwordHash";
        value = {
          sopsFile = "${inputs.secrets}/secrets/${host}/secrets.yaml";
          neededForUsers = true;
        };
      }) (lib.filterAttrs (_: user: user.setPassword) cfg.users)
      # The claude user's Gerrit identity, the same on every host
      // lib.optionalAttrs (cfg.users ? claude) (lib.genAttrs ["claude/ssh-key" "claude/netrc"] (_: {
        sopsFile = "${inputs.secrets}/secrets/${host}/secrets.yaml";
        owner = "claude";
      }));
  };
}
