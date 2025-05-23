{
  pkgs,
  ...
}: {
  imports = [
    ./aerospace
  ];

  environment.systemPackages = with pkgs; [
    raycast
    mos
  ];

  homebrew = {
    taps = [
      # "FelixKratz/formulae"
    ];
    brews = [
      # "svim"
    ];
    casks = [
      "homerow"
      "karabiner-elements"
      "battery"
      "macs-fan-control"
    ];
  };
}
