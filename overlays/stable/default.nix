{inputs, ...}: _final: prev: {
  nixpkgs-stable = inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system};
}
