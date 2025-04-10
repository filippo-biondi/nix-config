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
      "FelixKratz/formulae"
      "gerlero/openfoam"
    ];
    brews = [
      # "svim"
   ];
    casks = [
      "paraview"
      "battery"
      "lm-studio"
      "whatsapp"
      "homerow"
      "openfoam"
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
