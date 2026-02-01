{pkgs, ...}: {
  imports = [
    ../../../shared/config
  ];

  nix-rosetta-builder = {
    enable = true;
    onDemand = true;
    onDemandLingerMinutes = 120;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  power.sleep.display = 10;

  environment.systemPackages = with pkgs; [
    macpm
  ];
}
