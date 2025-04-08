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
    taps = [ "FelixKratz/formulae" ];
    brews = [
      # "svim"
   ];
    casks = [
      "paraview"
      "karabiner-elements"
      "battery"
      "ukelele"
      "lm-studio"
      "whatsapp"
      "homerow"
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
