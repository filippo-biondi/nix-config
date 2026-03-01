{inputs, ...}: _final: prev: {
  stable = inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system};
}
