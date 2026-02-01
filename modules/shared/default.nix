{lib, ...}: let
  allFiles = lib.filesystem.listFilesRecursive ./.;

  modules =
    builtins.filter (
      path: (lib.strings.hasSuffix "default.nix" (builtins.toString path)) && (path != ./default.nix)
    )
    allFiles;
in {
  imports = modules;
}
