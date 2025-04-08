{
  inputs,
  lib,
  config,
  userConfig,
  pkgs,
  ...
}: {
  # Nixpkgs configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Register flake inputs for nix commands
  nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) (lib.filterAttrs (_: lib.isType "flake") inputs);

  # Nix configuration
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  console.keyMap = "qwerty/us-acentos";

  # Timezone
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "it_IT.UTF-8";
      LC_IDENTIFICATION = "it_IT.UTF-8";
      LC_MEASUREMENT = "it_IT.UTF-8";
      LC_MONETARY = "it_IT.UTF-8";
      LC_NAME = "it_IT.UTF-8";
      LC_NUMERIC = "it_IT.UTF-8";
      LC_PAPER = "it_IT.UTF-8";
      LC_TELEPHONE = "it_IT.UTF-8";
      LC_TIME = "it_IT.UTF-8";
    };
  };

  # User configuration
  users.users.${userConfig.name} = {
    isNormalUser = true;
    description = userConfig.fullName;
    hashedPasswordFile = config.sops.secrets."password".path;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gcc
    glib
    wget
    curl
    unzip
    mesa
    killall
    btop
    docker-compose
  ];

  # Docker configuration
  virtualisation.docker.enable = true;

  # Zsh configuration
  programs.zsh.enable = true;

  # Connect tunnel configuration
  programs.connect-tunnel.enable = true;

  # Additional services
  services.devmon.enable = true;
  services.locate.enable = true;

  # Ssh configuration
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
}
