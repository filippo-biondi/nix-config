{
  inputs,
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (inputs.self.checks.${system}.pre-commit-check) shellHook enabledPackages;
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
