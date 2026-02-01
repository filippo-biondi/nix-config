{inputs, ...}: final: _prev: {
  nightly = import inputs.nixpkgs-nightly {
    inherit (final) system config;
  };
}
