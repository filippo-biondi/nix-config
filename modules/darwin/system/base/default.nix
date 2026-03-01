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

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    macpm
  ];
}
