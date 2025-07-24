{
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    ./media
    ./misc
    ./paraview
    ./social
  ];

  programs.firefox.enable = true;
}
