{
  pkgs,
  lib,
  ...
}: {
  options = {
    ccg.usersCatalog = lib.ccg.mkOpt' lib.types.attrs {};
  };
  config.ccg.usersCatalog = rec {
    server-msi = {
      filippo = {
        fullName = "Filippo Biondi";
        email = "filibiondi2000@gmail.com";
        sshKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArV7DUbiqZYLwtF5tZVQTskVPYJzaltXqZzVYJrxJwy"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/YrxCxrCU2AC8CPuDSgwovd4KHoacdoDfuveiX5FVG"
        ];
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "networkmanager" "docker" ];
        setPassword = true;
      };
      matteo = {
        fullName = "Matteo Tolloso";
        sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICYhWjAETWEB1YdT3Hn1xDEiJWbtAScaoi5+auEq1SQM" ];
        shell = pkgs.bash;
        extraGroups = [ "docker" ];
      };
      vornao = {
        fullName = "Luca Miglior";
        sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF65PNkzAPb12J2BV/Jzc79+BZ8RIlLJPDz6tOta21Cj" ];
        shell = pkgs.bash;
        extraGroups = [ "docker" ];
      };
    };

    macbook-pro = {
      filippo = server-msi.filippo // {
        sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5XH2x57j86zBf2eMDkEhjHBeIOuGdxWsc358WfcQT" ];
      };
    };

    server-stella = server-msi;

    server-casa = {
      filippo = server-msi.filippo;
    };
  };
}
