{
  inputs,
  pkgs,
  mkShell,
  ...
}: let
  inherit (inputs.self.checks.${pkgs.system}.pre-commit-check) shellHook enabledPackages;
in
  mkShell {
    inherit shellHook;
    buildInputs = enabledPackages;
    packages = with pkgs; [
      sops
      ssh-to-age
      age
      git
      ccg.sys
    ];
  }
