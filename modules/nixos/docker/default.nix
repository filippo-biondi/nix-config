{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.docker;
in {
  options.ccg.docker.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    # Rootless: each user runs their own daemon, so Docker never grants root
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
      # GPUs: `docker run --device nvidia.com/gpu=all` reads the spec nvidia-container-toolkit writes here
      daemon.settings = lib.mkIf config.hardware.nvidia-container-toolkit.enable {
        cdi-spec-dirs = ["/var/run/cdi"];
      };
    };
  };
}
