{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    sops
    step-cli
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    btop
    uv
    devour-flake
    cachix
    tree
  ];
}
