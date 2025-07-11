{
  inputs,
  ...
}: {
  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  old-packages = final: prev: {
    old = import inputs.nixpkgs-old {
      system = final.system;
      config.allowUnfree = true;
    };
  };
  nightly-packages = final: prev: {
    nightly = import inputs.nixpkgs-nightly {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  devour-flake = final: prev: {
    devour-flake = final.callPackage inputs.devour-flake { };
  };

  nvim = inputs.nvim.overlays.default;
  devenv = inputs.devenv.overlays.default;

  qt_fix = import ./qt;
}
