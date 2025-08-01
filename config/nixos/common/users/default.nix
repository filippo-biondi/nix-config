{
  pkgs,
  lib,
  config,
  users,
  userConfig,
  ...
}: {
  users = {
    mutableUsers = false;
    users = lib.mapAttrs (name: value: let
      isMainUser = name == userConfig.username;
      mainUserConfig = {
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        # hashedPasswordFile = config.sops.secrets."password".path;
        password = "test";
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
