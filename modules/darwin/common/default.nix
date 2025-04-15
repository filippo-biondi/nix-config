{
  outputs,
  pkgs,
  userConfig,
  ...
}:{
  imports = [
    ./users
    ./settings
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.old-packages
      outputs.overlays.qt_fix
    ];
    config.allowUnfree = true;
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
    };
    optimise.automatic = true;
    package = pkgs.nix;
  };

  # Add ability to use TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Power configration
  power.sleep.display = 10;
  power.sleep.computer = "never";

  # Zsh configuration
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    asitop
    colima
    docker
  ];

  # When karabiner will be fixed renable this
  # services.karabiner-elements.enable = true;

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
