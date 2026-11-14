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
          # The MacBook's, in its Secure Enclave
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGQOSLlZJgCcoXn2V77A5MuxfA/soGLE95P6Iu4+i+wrf1L1i8qudxrWtFNOtblV5HrA8fnFhaR86D4vT+HR5DA= macbook"
          # The MacBook's file key, until the one above is in use everywhere
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArV7DUbiqZYLwtF5tZVQTskVPYJzaltXqZzVYJrxJwy macbook-file"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/YrxCxrCU2AC8CPuDSgwovd4KHoacdoDfuveiX5FVG phone"
        ];
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        setPassword = true;
        linger = true;
      };
      matteo = {
        fullName = "Matteo Tolloso";
        sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICYhWjAETWEB1YdT3Hn1xDEiJWbtAScaoi5+auEq1SQM"];
        shell = pkgs.bash;
        linger = true;
      };
      vornao = {
        fullName = "Luca Miglior";
        sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF65PNkzAPb12J2BV/Jzc79+BZ8RIlLJPDz6tOta21Cj"];
        shell = pkgs.bash;
      };
      claude = {
        fullName = "Claude";
        email = "claude@server-msi.taild98f5.ts.net";
        shell = pkgs.bash;
        linger = true;
      };
    };

    server-stella = server-msi;

    server-casa = {
      inherit (server-msi) filippo;
    };

    installer = {
      filippo =
        server-msi.filippo
        // {
          setPassword = false;
        };
    };
  };
}
