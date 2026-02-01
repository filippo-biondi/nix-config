{
  config,
  host,
  ...
}: {
  ccg.desktop.ux.enable = true;

  ccg.desktop = {
    games.enable = true;
    misc.enable = true;
    office.enable = false;
    whatsapp.enable = true;
  };

  ccg.docker.enable = true;
  ccg.system.homebrew = {
    enable = true;
  };

  ccg.system.fonts.enable = true;

  ccg.networking.core = {
    enable = true;
    hostname = host;
  };

  ccg.users = config.ccg.usersCatalog.${host};

  system.primaryUser = "filippo";

  system.stateVersion = 6;
}
