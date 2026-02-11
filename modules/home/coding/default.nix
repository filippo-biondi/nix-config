{
  lib,
  config,
  ...
}: let
  cfg = config.ccg.coding;
in {
  options.ccg.coding.enable = lib.mkEnableOption "Enable all coding modules";

  config = lib.mkIf cfg.enable {
    ccg.coding = {
      vscode.enable = true;
      nvim.enable = true;
      gemini.enable = true;
      jetbrains.enable = true;
    };
  };
}
