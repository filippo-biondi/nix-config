{
  outputs,
  pkgs,
  hostname,
  ...
}:{
  imports = [
    ../../common
    ./users
    ./settings
    ./homebrew
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.old-packages
      outputs.overlays.qt_fix
      outputs.overlays.nightly-packages
    ];
    config.allowUnfree = true;
  };

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 3;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 50 * 1024;
          memorySize = 20 * 1024;
        };
        cores = 6;
      };
    };
  };

  networking.hostName = hostname;

  # Add ability to use TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Power configration
  power.sleep.display = 10;
  power.sleep.computer = "never";

  # Zsh configuration
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    asitop
  ];

  # When karabiner will be fixed renable this
  # services.karabiner-elements.enable = true;

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
}
