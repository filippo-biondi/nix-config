{ userConfig,
  ...
}: {
 # Add nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "${userConfig.name}";
  };

  homebrew = {
    enable = true;
    brews = [];
    casks = [
      "paraview"
      "karabiner-elements"
    ];
    taps = [];
    masApps = {};
    global.autoUpdate = false;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };
}
