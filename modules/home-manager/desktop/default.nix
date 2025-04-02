{
  pkgs,
  ...
}: {
  imports = [
    ../programs/alacritty
    ../programs/vscode
  ];

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
  ]
  ++ lib.optionals (!stdenv.isDarwin) [
    paraview
    vlc
    obs-studio
    quickemu
    freecad-wayland
    wl-clipboard
    bitwarden-desktop
  ]
  ++ lib.optionals (stdenv.isDarwin) [
    raycast
  ];
}
