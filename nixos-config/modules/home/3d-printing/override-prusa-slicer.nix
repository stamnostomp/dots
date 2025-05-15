# modules/home/3d-printing/prusa-slicer.nix
# This module overrides the prusa-slicer package with a wrapped version

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Create a wrapped version of PrusaSlicer
  wrapped-prusa-slicer = pkgs.symlinkJoin {
    name = "prusa-slicerwrapped";
    paths = [ pkgs.prusa-slicer ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Rename the binary
      mv $out/bin/prusa-slicer $out/bin/prusa-slicer-original

      # Create wrapper script
      makeWrapper $out/bin/prusa-slicer-original $out/bin/prusa-slicer \
        --set GTK_THEME "Adwaita:light" \
        --set GDK_BACKEND "x11" \
        --unset GTK2_RC_FILES \
        --set XDG_DATA_DIRS "/run/current-system/sw/share:/usr/share:$XDG_DATA_DIRS" \
        --set NO_AT_BRIDGE "1" \
        --set GTK_CELL_LAYOUT_IGNORE_CONFLICTS "1" \
        --set GTK_IGNORE_ASSERT_FAILURES "1"
    '';
  };
in
{
  # Override the prusa-slicer package
  nixpkgs.overlays = [
    (final: prev: {
      prusa-slicer = wrapped-prusa-slicer;
    })
  ];
}
