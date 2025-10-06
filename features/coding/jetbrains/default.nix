{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    jetbrains.pycharm-professional
    jetbrains.clion
    jetbrains.idea-ultimate
    jetbrains.webstorm
    jetbrains.gateway
  ];
}
