{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.ccg.games.factorio;
in {
  options.ccg.games.factorio.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    services.factorio = {
      enable = true;
      package = pkgs.nightly.factorio-headless;
      username = "Dielink";
      extraSettingsFile = config.sops.secrets."factorio/password".path;
      admins = ["Dielink"];
      allowedPlayers = [
        "Dielink"
        "JustoFranko"
        "MatteOne17"
      ];
      public = false;
      lan = true;
      game-name = "MSI Factorio Server";
      description = "A beautiful Factorio server hosted on msi-server";
      requireUserVerification = false;
      loadLatestSave = false;
      saveName = "yag";
      mods = [];
    };

    sops.secrets."factorio/password" = {
      sopsFile = ../../../../secrets/factorio.yaml;
    };
  };
}
