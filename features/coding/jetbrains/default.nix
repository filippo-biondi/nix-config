{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    jetbrains.pycharm-professional
    jetbrains.clion
    jetbrains.gateway
  ];
}
