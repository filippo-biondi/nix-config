_: {
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = false;
  programs.alejandra.enable = true;
  programs.statix.enable = true;
  programs.deadnix.enable = true;

  # Example: Format shell scripts too
  programs.shfmt.enable = true;
}
