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
    qutebrowser
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
    ];
  };
}
