{
  pkgs,
  ...
}: {

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Enables support for Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable the windowing system.
  services.xserver ={
    enable = true;
    xkb = {
      layout = "us";
      variant = "alt-intl";
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xorg.xhost
  ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
}
