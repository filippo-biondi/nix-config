{
  pkgs,
  lib,
  config,
  users,
  userConfig,
  ...
}: {
  users.users = lib.mapAttrs (name: value: let
    isMainUser = name == userConfig.username;
  in {
    isNormalUser = true;
    description = value.fullName;
    extraGroups = if isMainUser
      then [ "networkmanager" "wheel" "docker" ]
      else [ "docker" ];
    shell = pkgs.${value.shell};
    openssh.authorizedKeys.keys = value.sshKeys;
  } // lib.optionalAttrs isMainUser { hashedPasswordFile = config.sops.secrets."password".path; }) users;
}
