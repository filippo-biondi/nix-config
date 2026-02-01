{
  config,
  lib,
  ...
}:
with lib;
with lib.ccg; let
  cfg = config.ccg.hardware.audio;
in {
  options.ccg.hardware.audio = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };
    programs.noisetorch.enable = true;
  };
}
