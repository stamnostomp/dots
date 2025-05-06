# nixos-config/overlays/everblush-gtk.nix
final: prev: {
  everblush-gtk = prev.everblush-gtk.overrideAttrs (oldAttrs: {
    # Keep the original package but add our transparency modifications
    postInstall = ''
      ${oldAttrs.postInstall or ""}

      # Create transparency CSS for GTK-3.0
      cat >> $out/share/themes/Everblush/gtk-3.0/gtk.css << EOF
      /* Transparency overrides */
      window.background {
        background-color: rgba(20, 27, 30, 0.90);
        border-radius: 8px;
      }

      .nautilus-window, .thunar, .pcmanfm-main-window {
        background-color: rgba(20, 27, 30, 0.85);
      }

      popover, menu, .menu, .context-menu {
        background-color: rgba(35, 42, 45, 0.95);
      }

      headerbar {
        background-color: rgba(35, 42, 45, 0.95);
      }
      EOF

      # Create the same for GTK-4.0 if the directory exists
      if [ -d "$out/share/themes/Everblush/gtk-4.0" ]; then
        cat >> $out/share/themes/Everblush/gtk-4.0/gtk.css << EOF
      /* Transparency overrides */
      window.background {
        background-color: rgba(20, 27, 30, 0.90);
        border-radius: 8px;
      }

      .nautilus-window, .thunar, .pcmanfm-main-window {
        background-color: rgba(20, 27, 30, 0.85);
      }

      popover, menu, .menu, .context-menu {
        background-color: rgba(35, 42, 45, 0.95);
      }

      headerbar {
        background-color: rgba(35, 42, 45, 0.95);
      }
      EOF
      fi
    '';
  });
}
