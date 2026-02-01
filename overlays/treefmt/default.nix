{inputs, ...}: _final: prev: {
  treefmt-configured = (inputs.treefmt-nix.lib.evalModule prev ./treefmt.nix).config.build.wrapper;
}
