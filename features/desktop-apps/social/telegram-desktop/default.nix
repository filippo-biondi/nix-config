{
  pkgs,
  ...
}: let
  telegram-unwrapped-darwin = pkgs.telegram-desktop.unwrapped.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./telegram-desktop-shortcut.patch
    ];
  });
  telegram-darwin = pkgs.telegram-desktop.overrideAttrs (old: {
    unwrapped = telegram-unwrapped-darwin;
  });
in {
home.packages = with pkgs;
    if pkgs.stdenv.isDarwin then
      [ telegram-darwin ]
    else
      [ telegram-desktop ];
}
