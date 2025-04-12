{
  config,
  hostname,
  ...
}: {
  services.tailscale = {
    enable = true;
      authKeyFile = "${config.sops.secrets."${hostname}-tailscale/authkey".path}";
  };
}
