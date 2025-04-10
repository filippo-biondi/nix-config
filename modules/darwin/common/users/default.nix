{
  pkgs,
  lib,
  users,
  ...
}: {
  users.users = lib.mapAttrs (name: value: {
    home = "/Users/${name}";
    createHome = true;
    description = value.fullName;
    shell = pkgs.${value.shell};
    openssh.authorizedKeys.keys = value.sshKeys;
  }) users;
}

