{
  pkgs,
  ...
}: {
  homebrew.casks = [
    "balenaetcher"
    "ultimaker-cura"
    "kicad"
    "skim"
  ];

  environment.systemPackages = with pkgs; [
    utm
  ];
}
