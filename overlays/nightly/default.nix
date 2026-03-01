{inputs, ...}: final: _prev: {
  nightly = import inputs.nixpkgs-nightly {
    inherit (final.stdenv.hostPlatform) system;
    inherit (final) config;
  };
}
