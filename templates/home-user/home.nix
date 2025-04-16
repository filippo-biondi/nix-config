{ pkgs, ... }:

{
  # Add here the packages that you want to install
  # Check https://search.nixos.org/packages to find packages
  home.packages = with pkgs; [
    htop
    git
  ];

  # Some programs provides a richer configuration
  # Check on https://mynixos.com for pprograms starting with "home-manager/option/programs"
  programs.zsh = {
    enable = true;
    # ohMyZsh.enable = true;
    # ohMyZsh.theme = "agnoster";
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}

