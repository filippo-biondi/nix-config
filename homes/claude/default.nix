{
  config,
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

  programs.claude-code.plugins = {
    review = "${inputs.claude-plugins}/plugins/review";
    config-manager = "${inputs.claude-plugins}/plugins/config-manager";
  };

  # The review skills push to Gerrit through this host, with the agent's own key
  ccg.cli.ssh.gerrit = {
    enable = true;
    alias = "gerrit-claude";
    user = "claude";
  };

  home.stateVersion = "26.05";
}
