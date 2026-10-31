{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.coding.claude-code;
in {
  options.ccg.coding.claude-code = {
    enable = lib.ccg.mkBoolOpt' false;
    remoteControl.enable = lib.ccg.mkBoolOpt' false;
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code.enable = true;

    # Lets claude.ai/code and the Claude app start sessions on this machine
    systemd.user.services.claude-remote-control = lib.mkIf cfg.remoteControl.enable {
      Unit.Description = "Claude Code Remote Control";
      Service = {
        ExecStart = "${lib.getExe config.programs.claude-code.finalPackage} remote-control";
        WorkingDirectory = "%h";
        # Sessions run the user's and the system's tools
        Environment = "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";
        Restart = "on-failure";
        RestartSec = 60;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
