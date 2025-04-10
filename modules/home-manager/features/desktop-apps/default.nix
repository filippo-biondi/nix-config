{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    discord
    zotero
    telegram-desktop
    signal-desktop
    jetbrains.pycharm-professional
    jetbrains.gateway
    jetbrains.webstorm
    spotify
    neovide
    element-desktop
  ]
  ++ lib.optionals (!stdenv.isDarwin) [
    paraview
    vlc
    obs-studio
    quickemu
    freecad-wayland
    wl-clipboard
    bitwarden-desktop
  ];
}
