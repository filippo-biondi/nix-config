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
      "giovanni" = {
        hostname = "192.168.83.20";
        user = "fbiondi";
        forwardX11 = true;
        forwardX11Trusted = true;
      };
    };
  };
}
