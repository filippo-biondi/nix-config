{
  lib,
  pkgs,
  config,
  osConfig,
  host,
  inputs,
  ...
}: {
  ccg.cli.git = {
    enable = true;
    user = config.ccg.usersCatalog.${host}.claude;
  };

  ccg.coding.claude-code = {
    enable = true;
    remoteControl = {
      enable = true;
      directory = "%h/workspace";
    };
  };

  programs.claude-code = {
    plugins.core = "${inputs.claude-plugins}/plugins/core";

    context = ''
      You are running on the NixOS host ${host}, as the `claude` user.
      The host's configuration is nix-config, checked out in ~/workspace/nix-config.
      Before changing it, load the /core:nix-config skill.

      @${inputs.claude-plugins}/plugins/core/preferences.md
    '';
  };

  # The review skills push to Gerrit through this host, with the agent's own key
  ccg.cli.ssh.gerrit = {
    enable = true;
    alias = "gerrit-claude";
    user = "claude";
  };
  programs.ssh.settings.gerrit-claude = {
    IdentityFile = osConfig.sops.secrets."claude/ssh-key".path;
    # The clone below runs with nobody to answer the prompt
    StrictHostKeyChecking = "accept-new";
  };

  # The review skills sign in to Gerrit's REST API from this file
  home.file.".netrc" = {
    source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets."claude/netrc".path;
    force = true;
  };

  # The checkout CLAUDE.md points to. Retries until Gerrit can be reached
  systemd.user.services.clone-nix-config = {
    Unit = {
      Description = "Clone nix-config for the agent";
      ConditionPathExists = "!%h/workspace/nix-config";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.git} clone ssh://gerrit-claude/nix-config %h/workspace/nix-config";
      Environment = "PATH=${lib.makeBinPath [pkgs.openssh]}";
      Restart = "on-failure";
      RestartSec = 60;
    };
    Install.WantedBy = ["default.target"];
  };

  home.stateVersion = "26.05";
}
