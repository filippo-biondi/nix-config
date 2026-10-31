{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ccg.coding.claude-code;
in {
  options.ccg.coding.claude-code = {
    enable = lib.ccg.mkBoolOpt' false;
    remoteControl = {
      enable = lib.ccg.mkBoolOpt' false;
      # Sessions start here. Claude Code never saves trust for the home folder,
      # so it has to be a project folder, trusted once by running claude in it
      directory = lib.ccg.mkOpt' lib.types.str null;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code.enable = true;

    # Lets claude.ai/code and the Claude app start sessions on this machine
    systemd.user.services.claude-remote-control = lib.mkIf cfg.remoteControl.enable {
      Unit.Description = "Claude Code Remote Control";
      Service = {
        ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p ${cfg.remoteControl.directory}";
        ExecStart = "${lib.getExe config.programs.claude-code.finalPackage} remote-control";
        # "-": the folder may not exist yet when ExecStartPre creates it
        WorkingDirectory = "-${cfg.remoteControl.directory}";
        # Sessions run the user's and the system's tools
        Environment = "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";
        Restart = "on-failure";
        RestartSec = 60;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
