{
  pkgs,
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    ./telegram-desktop
    ./whatsapp
  ];

  home.packages = with pkgs; [
    discord
    element-desktop
  ]++ (if pkgs.stdenv.isDarwin then [
    signal-desktop-bin
  ]
  else [
    signal-desktop
  ]);
}
