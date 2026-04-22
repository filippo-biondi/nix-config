{lib, ...}: {
  imports = [../../filippo];

  ccg.coding.jetbrains.enable = lib.mkForce true;
}
