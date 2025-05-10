{
  pkgs,
  ...
}: {
  home.packages = with pkgs; lib.optionals (!pkgs.stdenv.isDarwin) [
    whatsapp-for-linux
  ];
}
