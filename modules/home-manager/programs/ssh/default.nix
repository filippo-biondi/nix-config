{ ... }: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "g100" = {
        hostname = "login.g100.cineca.it";
        user = "fbiondi0";
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
      "giovanni-direct" = {
        hostname = "192.168.83.20";
        user = "fbiondi";
        forwardX11 = true;
        forwardX11Trusted = true;
      };
      "msi" = {
        hostname = "100.118.250.64";
        user = "filippo";
      };
      "giovanni" = {
        hostname = "192.168.83.20";
        user = "fbiondi";
        proxyJump = "msi";
        forwardX11 = true;
        forwardX11Trusted = true;
      };
    };
  };
}
