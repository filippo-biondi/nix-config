{
  pkgs,
  lib,
  users,
  ...
}: let
  names = lib.attrNames users;
in {
  users.users = lib.mapAttrs (name: value: {
    home = "/Users/${name}";
    createHome = true;
    description = value.fullName;
    shell = pkgs.${value.shell};
    openssh.authorizedKeys.keys = value.sshKeys;
  }) users;

  system.primaryUser = builtins.head (lib.filter (n: users.${n}.primaryUser) names);
}

