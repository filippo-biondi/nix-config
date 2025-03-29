{
  userConfig,
  ...
}: {
  programs.git = {
    enable = true;
    userName = userConfig.fullName;
    userEmail = userConfig.email;
    extraConfig = {
      init.defaultBranch = "main";
      color.ui = "auto";
    };
  };
}
