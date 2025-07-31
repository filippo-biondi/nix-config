{ }: rec {
  msi = {
    filippo = {
      fullName = "Filippo Biondi";
      email = "filibiondi2000@gmail.com";
      sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArV7DUbiqZYLwtF5tZVQTskVPYJzaltXqZzVYJrxJwy" ];
      shell = "zsh";
    };
    matteo = {
      fullName = "Matteo Tolloso";
      sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICYhWjAETWEB1YdT3Hn1xDEiJWbtAScaoi5+auEq1SQM" ];
      shell = "bash";
    };
    vornao = {
      fullName = "Luca Miglior";
      sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF65PNkzAPb12J2BV/Jzc79+BZ8RIlLJPDz6tOta21Cj" ];
      shell = "bash";
    };
  };

  giova-sssa = {
    fbiondi = msi.filippo // {
      email = "filippo.biondi@santannapisa.it";
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5XH2x57j86zBf2eMDkEhjHBeIOuGdxWsc358WfcQT"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArV7DUbiqZYLwtF5tZVQTskVPYJzaltXqZzVYJrxJwy"
      ];
    };
  };

  macbook-pro = {
    filippo = msi.filippo // {
      primaryUser = true;
      sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5XH2x57j86zBf2eMDkEhjHBeIOuGdxWsc358WfcQT" ];
    };
  };

  server-stella = msi;

  server-casa = {
    filippo = msi.filippo;
  };
}
