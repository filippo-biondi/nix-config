{
  config,
  host,
  ...
}: {
  ccg.cli.git = {
    enable = true;
    user = config.ccg.usersCatalog.${host}.claude;
  };

  ccg.coding.claude-code = {
    enable = true;
    remoteControl.enable = true;
  };

  # The review skills push to Gerrit through this host, with the agent's own key
  ccg.cli.ssh.gerrit = {
    enable = true;
    alias = "gerrit-claude";
    user = "claude";
  };

  home.stateVersion = "26.05";
}
