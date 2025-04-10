{
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers
      catppuccin.catppuccin-vsc
      vscodevim.vim
      yzhang.markdown-all-in-one
    ];
  };
}
