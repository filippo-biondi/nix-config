{
  pkgs,
  ...
}: {
  homebrew.casks = [
    "balenaetcher"
    "ultimaker-cura"
    "kicad"
  ];

  environment.systemPackages = with pkgs; [
    utm
  ];
}
