{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    zotero
    neovide
  ]
  ++ lib.optionals (!stdenv.isDarwin) [
    kicad
    wl-clipboard
    bitwarden-desktop
    bitwarden-cli
  ];
}
