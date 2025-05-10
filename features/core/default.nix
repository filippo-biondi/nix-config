{
  suffix_imports,
  ...
}: {
  imports = suffix_imports [
    ./alacritty
    ./direnv
    ./git
    ./misc
    ./ssh
    ./zsh
  ];
}
