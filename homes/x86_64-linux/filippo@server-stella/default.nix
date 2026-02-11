{
  lib,
  ...
}: {
  imports = [../../filippo];

  config = {
    ccg.desktop.social.enable = lib.mkForce false;
    ccg.desktop.media.enable = lib.mkForce false;
    ccg.desktop.utils.enable = lib.mkForce false;
  };
}
