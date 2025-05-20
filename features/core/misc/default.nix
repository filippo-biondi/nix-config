{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    sops
    step-cli
    nerd-fonts.jetbrains-mono
    btop
    uv
  ];
}
