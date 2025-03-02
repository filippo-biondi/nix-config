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
    paraview
    spotify
    vlc
    obs-studio
    quickemu
  ];
}
