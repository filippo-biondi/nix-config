{ userConfig,
  ...
}: {
 # Add nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "${userConfig.username}";
  };

  homebrew = {
    enable = true;
    taps = [
      "gerlero/openfoam"
    ];
    brews = [];
    casks = [
      "paraview"
      "battery"
      "lm-studio"
      "whatsapp"
      "homerow"
      "openfoam"
      "surfshark"
      "steam"
      "balenaetcher"
    ];
    masApps = {};
    global.autoUpdate = false;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };
}
