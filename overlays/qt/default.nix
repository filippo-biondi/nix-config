final: prev: {
  qt6 = prev.qt6.overrideScope (final: prev: {
    qtbase = prev.qtbase.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ./qtbase-shortcut.patch
      ];
    });
  });
}
