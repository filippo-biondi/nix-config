{
  userConfig,
  ...
}: {
  programs.git = {
    enable = true;
    userName = userConfig.fullName;
    userEmail = userConfig.email;
    aliases = {
      undo = "reset HEAD~1 --mixed";
    };
    extraConfig = {
      init.defaultBranch = "main";
      color.ui = "auto";
    };
  };
}
