{
  pkgs,
  ...
}:{
  # Nix configuration
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      substituters = [
        "https://devenv.cachix.org"
        "https://filippo-biondi.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "filippo-biondi.cachix.org-1:eFsEqQ04EN/mBrQB6etml2kKB2FNP54MgMy2jCsYpfU="
      ];
      trusted-users = [ "@admin" ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    } // (if pkgs.stdenv.isDarwin then {
      interval = {
        Weekday = 7;
      };
    } else {
      dates = "weekly";
    });
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 3;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 30 * 1024;
            memorySize = 20 * 1024;
          };
          cores = 6;
        };
      };
    };
  };
}
