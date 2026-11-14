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
      # Encrypts to the age key in the MacBook's Secure Enclave
      age-plugin-se
      git
      # Deploys packages/backups-stack
      awscli2
    ];
  }
