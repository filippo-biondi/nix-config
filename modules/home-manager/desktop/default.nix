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
    jetbrains.pycharm-professional
    jetbrains.gateway
    jetbrains.webstorm
    paraview
    spotify
    vlc
    obs-studio
    quickemu
    wl-clipboard
    bitwarden-desktop
    freecad-wayland
  ];
}
