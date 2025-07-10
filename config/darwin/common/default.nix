{
  outputs,
  pkgs,
  hostname,
  ...
}:{
  imports = [
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

  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      substituters = [
        "https://devenv.cachix.org"
        "https://filippo-biondi.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "filippo-biondi.cachix.org-1:eFsEqQ04EN/mBrQB6etml2kKB2FNP54MgMy2jCsYpfU="
      ];
    };
    optimise.automatic = true;
    package = pkgs.nix;
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
  ];
}
