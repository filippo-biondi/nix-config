{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.system.print;
in {
  options.ccg.system.print.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {
    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
