{
  outputs,
  pkgs,
  userConfig,
  ...
}:{
  imports = [
    ../programs/aerospace
    ../programs/homebrew
    ../services/tailscale
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.old-packages
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

  # User configuration
  users.users.${userConfig.name} = {
    name = "${userConfig.name}";
    home = "/Users/${userConfig.name}";
  };

  # Add ability to use TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Zsh configuration
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    asitop
    swift-quit
    colima
    docker
    docker-compose
  ];


  # When karabiner will be fixed renable this
  # services.karabiner-elements = {
  #   enable = true;
  #   package = pkgs.old.karabiner-elements;
  # };

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
