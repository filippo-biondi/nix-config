{
  pkgs,
  config,
  hostname,
  ...
}: {
  services.factorio = {
    enable = true;
    package = pkgs.nightly.factorio-headless;
    username = "Dielink";
    extraSettingsFile = config.sops.secrets."factorio/password".path;
    admins = [ "Dielink" ];
    allowedPlayers = [ "Dielink" "JustoFranko" "MatteOne17" ];
    public = true;
    lan = true;
    game-name = "MSI Factorio Server";
    description = "A beautiful Factorio server hosted on msi-server";
    requireUserVerification = true;
    loadLatestSave = true;
    mods = [];
  };
}
