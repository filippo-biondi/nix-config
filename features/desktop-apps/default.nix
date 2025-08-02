{
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    ./media
    ./misc
    ./social
  ];

  programs.firefox.enable = true;
}
