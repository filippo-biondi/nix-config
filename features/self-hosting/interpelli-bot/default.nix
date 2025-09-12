{
  config,
  ...
}: {
  services.interpelli-bot = {
    enable = true;
    environmentFile = config.sops.secrets."interpelli-bot-key".path;
  };
}
