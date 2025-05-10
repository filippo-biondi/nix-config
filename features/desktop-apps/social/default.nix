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
    signal-desktop
    element-desktop
  ];
}
