{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    spotify
  ] ++ (if pkgs.stdenv.isDarwin then [
    vlc-bin
  ]
  else [
    vlc
  ]);
}
