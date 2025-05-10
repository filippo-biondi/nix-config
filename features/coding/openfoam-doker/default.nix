{
  pkgs,
  ...
}: let
    openfoam-container-script = pkgs.fetchgit {
      url = "https://develop.openfoam.com/packaging/containers.git";
      rev = "50f4b8c77ca610ec33d1ba7ba336157091f018d8";
      sha256 = "sha256-wv2QoHFIiV+Gsz+pwVt42ithHJ1LL1KL8pZ5PbAgDXk=";
    };
    openfoam-container-bin = pkgs.writeScriptBin "openfoam-docker" (builtins.readFile "${openfoam-container-script}/openfoam-docker");
  in {
    home.packages = [
      openfoam-container-bin
    ];
  }
