{
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    ./alacritty
    ./devenv
    ./direnv
    ./git
    ./misc
    ./ssh
    ./zsh
  ];
}
