{
  pkgs,
  ...
}: {
  services.immich = {
    enable = true;
    package = pkgs.nightly.immich;
    host = "0.0.0.0";
    accelerationDevices = null;
    machine-learning.enable = true;
  };
}
