{ lib, pkgs }:

pkgs.symlinkJoin {
  name = "orca-slicer-fixed";
  paths = [ pkgs.orca-slicer ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    # Create a wrapped binary with the proper environment variables
    mkdir -p $out/bin
    makeWrapper ${pkgs.orca-slicer}/bin/orca-slicer $out/bin/orca-slicer \
      --set GTK_THEME "Adwaita:light" \
      --set GDK_BACKEND "x11" \
      --set LIBGL_DEBUG "verbose" \
      --set GTK2_RC_FILES "/run/current-system/sw/share/themes/Adwaita/gtk-2.0/gtkrc" \
      --set XDG_DATA_DIRS "/run/current-system/sw/share:$XDG_DATA_DIRS" \
      --set GTK_DATA_PREFIX "/run/current-system/sw" \
      --set GTK_PATH "/run/current-system/sw/lib/gtk-3.0" \
      --set GTK_EXE_PREFIX "/run/current-system/sw" \
      --set GDK_PIXBUF_MODULE_FILE "$(echo ${pkgs.gdk-pixbuf}/lib/gdk-pixbuf-2.0/*/loaders.cache)" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          pkgs.gtk3
          pkgs.glib
          pkgs.pango
          pkgs.cairo
          pkgs.gdk-pixbuf
          pkgs.atk
          pkgs.libGLU
          pkgs.mesa
          pkgs.mesa.drivers
        ]
      }"
  '';
}
