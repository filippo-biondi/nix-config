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

  programs.claude-code = {
    plugins.core = "${inputs.claude-plugins}/plugins/core";

    memory.text = ''
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

  home.stateVersion = "26.05";
}
