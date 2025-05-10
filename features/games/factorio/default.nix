
{
  pkgs,
  config,
  ...
}: {
  services.factorio = {
    enable = true;
    package = pkgs.nightly.factorio-headless;
    username = "Dielink";
    extraSettingsFile = config.sops.secrets."factorio/password".path;
    admins = [ "Dielink" ];
    allowedPlayers = [ "Dielink" "JustoFranko" "MatteOne17" ];
    public = false;
    lan = true;
    game-name = "MSI Factorio Server";
    description = "A beautiful Factorio server hosted on msi-server";
    requireUserVerification = false;
    # loadLatestSave = true;
    saveName = "gay2";
    mods = [];
  };
}
