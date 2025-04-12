{
  pkgs,
  lib,
  config,
  hostname,
  users,
  userConfig,
  ...
}: {
  users = {
    mutableUsers = true;
    users = lib.mapAttrs (name: value: let
      isMainUser = name == userConfig.username;
      mainUserConfig = {
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        hashedPasswordFile = config.sops.secrets."${hostname}-password".path;
      };
      otherUserConfig = {
        extraGroups = [ "docker" ];
      };
    in {
      isNormalUser = true;
      description = value.fullName;
      shell = pkgs.${value.shell};
      openssh.authorizedKeys.keys = value.sshKeys;
    } // (if isMainUser then mainUserConfig else otherUserConfig)) users;
  };
}
