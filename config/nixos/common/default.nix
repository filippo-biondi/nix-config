{
  inputs,
  outputs,
  lib,
  pkgs,
  hostname,
  ...
}: {
  imports = [
    ./users
  ];

  # Nixpkgs configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      outputs.overlays.nightly-packages
    ];
  };

  # Register flake inputs for nix commands
  nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) (lib.filterAttrs (_: lib.isType "flake") inputs);

  # Nix configuration
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      substituters = [
        "https://devenv.cachix.org"
        "https://filippo-biondi.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "filippo-biondi.cachix.org-1:eFsEqQ04EN/mBrQB6etml2kKB2FNP54MgMy2jCsYpfU="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };


  # Networking
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sudo
    git
    gcc
    glib
    wget
    curl
    unzip
    mesa
    killall
  ];

  # Zsh configuration
  programs.zsh.enable = true;

  # Connect tunnel configuration
  programs.connect-tunnel.enable = true;

  # Additional services
  services.devmon.enable = true;
  services.locate.enable = true;

  # Prevent sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Ssh configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  programs.ssh.startAgent = true;
}
