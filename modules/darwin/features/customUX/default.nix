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
    taps = [];
    brews = [];
    casks = [
      "homerow"
      "karabiner-elements"
    ];
  };
}
