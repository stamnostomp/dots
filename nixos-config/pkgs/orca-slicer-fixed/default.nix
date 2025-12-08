{ lib, pkgs, stdenv, makeWrapper }:

stdenv.mkDerivation {
  pname = "orca-slicer-fixed";
  version = pkgs.orca-slicer.version;

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    # Create wrapper that forces X11 and fixes GTK issues
    makeWrapper ${pkgs.orca-slicer}/bin/orca-slicer $out/bin/orca-slicer \
      --set GDK_BACKEND "x11" \
      --set QT_QPA_PLATFORM "xcb" \
      --set GTK_THEME "Adwaita:dark" \
      --unset WAYLAND_DISPLAY \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          pkgs.gtk3
          pkgs.glib
          pkgs.pango
          pkgs.cairo
          pkgs.gdk-pixbuf
          pkgs.libGL
          pkgs.mesa
        ]
      }"
  '';

  meta = with lib; {
    description = "Orca Slicer with fixes for NVIDIA + Wayland";
    inherit (pkgs.orca-slicer.meta) homepage license platforms;
  };
}
