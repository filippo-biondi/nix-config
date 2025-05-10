{
  config,
  ...
}: {
  services.tailscale = {
    enable = true;
      authKeyFile = "${config.sops.secrets."tailscale/authkey".path}";
  };
}
