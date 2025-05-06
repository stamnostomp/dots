# home/stamno/theme.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Import colors
  inherit (import ./theme/colors.nix) colors;

  # Cursor theme definition
  cursorTheme = {
    name = "Bibata-Modern-Classic";
    size = 20;
  };

  # Create a script derivation for the GTK transparency fix
  gtkTransparencyFix = pkgs.writeScriptBin "fix-gtk-transparency" ''
    #!/usr/bin/env bash

    # Define Everblush colors
    BACKGROUND="${colors.background}"
    BLACK="${colors.black}"
    CYAN="${colors.cyan}"
    FOREGROUND="${colors.foreground}"

    # Create GTK-3.0 settings if they don't exist
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"

    # Add specific transparency fixes to GTK-3.0 settings
    cat > "$HOME/.config/gtk-3.0/gtk.css" << EOF
    /* Fix for transparency issues in GTK apps */
    window, dialog, popover, menu {
      background-color: $BACKGROUND;
      box-shadow: none;
    }

    window.solid-csd, dialog.solid-csd {
      background-color: $BACKGROUND;
      box-shadow: none;
    }

    .background {
      background-color: $BACKGROUND;
    }

    /* Fix for some specific apps with transparency issues */
    .titlebar, headerbar {
      background-color: $BLACK;
      border-color: $BLACK;
    }

    /* Fix for context menus */
    menu, .menu, .context-menu {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }

    /* Additional fixes for popover widgets */
    popover > arrow,
    popover > contents {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }

    /* Fix for dropdown menus */
    combobox window.popup,
    combobox menu {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }

    /* Fix transparency for tooltips */
    tooltip {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }
    tooltip label {
      color: $FOREGROUND;
    }

    /* Fix for dialog buttons */
    button {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }
    button:hover {
      background-color: ${colors.brightBlack};
    }
    EOF

    # Apply the same fixes for GTK-4
    cat > "$HOME/.config/gtk-4.0/gtk.css" << EOF
    /* Fix for transparency issues in GTK apps */
    window, dialog, popover, menu {
      background-color: $BACKGROUND;
      box-shadow: none;
    }

    window.solid-csd, dialog.solid-csd {
      background-color: $BACKGROUND;
      box-shadow: none;
    }

    .background {
      background-color: $BACKGROUND;
    }

    /* Fix for some specific apps with transparency issues */
    .titlebar, headerbar {
      background-color: $BLACK;
      border-color: $BLACK;
    }

    /* Fix for context menus */
    menu, .menu, .context-menu {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }

    /* Additional fixes for popover widgets */
    popover > arrow,
    popover > contents {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }

    /* Fix for dropdown menus */
    combobox window.popup,
    combobox menu {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }

    /* Fix transparency for tooltips */
    tooltip {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }
    tooltip label {
      color: $FOREGROUND;
    }

    /* Fix for dialog buttons */
    button {
      background-color: $BLACK;
      border: 1px solid $CYAN;
    }
    button:hover {
      background-color: ${colors.brightBlack};
    }
    EOF

    # Create a fix for Flatpak apps
    mkdir -p "$HOME/.config/gtk-3.0/flatpak-overrides"
    mkdir -p "$HOME/.config/gtk-4.0/flatpak-overrides"

    cp "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/flatpak-overrides/gtk.css"
    cp "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/flatpak-overrides/gtk.css"

    echo "GTK transparency fixes applied. Please restart your applications."

    # Update theme setting in dconf (for GNOME/GTK apps)
    if command -v gsettings &> /dev/null; then
      gsettings set org.gnome.desktop.interface gtk-theme 'Everblush'
      gsettings set org.gnome.desktop.interface cursor-theme '${cursorTheme.name}'
      gsettings set org.gnome.desktop.interface cursor-size ${toString cursorTheme.size}
      echo "Updated GTK theme settings via gsettings."
    fi

    # Force reload for running applications
    if command -v xsettingsd &> /dev/null; then
      killall -HUP xsettingsd 2>/dev/null
    fi

    echo "Transparency fixes complete. Log out and back in for the best results."
  '';

  # Create a script derivation for cursor fix
  cursorFix = pkgs.writeScriptBin "fix-cursor" ''
    #!/usr/bin/env bash

    # Set cursor theme
    export XCURSOR_THEME="${cursorTheme.name}"
    export XCURSOR_SIZE="${toString cursorTheme.size}"

    # Create necessary directories
    mkdir -p $HOME/.icons
    mkdir -p $HOME/.local/share/icons

    # Create symbolic links to cursor theme
    ln -sf ${pkgs.apple-cursor}/share/icons/${cursorTheme.name} $HOME/.icons/
    ln -sf ${pkgs.apple-cursor}/share/icons/${cursorTheme.name} $HOME/.local/share/icons/

    # Explicitly set cursor with hyprctl if Hyprland is running
    if command -v hyprctl &>/dev/null && pgrep -x Hyprland &>/dev/null; then
      hyprctl setcursor "${cursorTheme.name}" "${toString cursorTheme.size}"
    fi

    echo "Cursor theme set to ${cursorTheme.name} with size ${toString cursorTheme.size}"
  '';
in
{
  # Set cursor environment variables consistently
  home.sessionVariables = {
    XCURSOR_PATH = "${config.home.profileDirectory}/share/icons:${pkgs.apple-cursor}/share/icons";
    XCURSOR_THEME = cursorTheme.name;
    XCURSOR_SIZE = toString cursorTheme.size;
    GTK_THEME = "Everblush";
    # Use mkForce to override the conflicting definition
    GTK2_RC_FILES = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc:${config.home.homeDirectory}/.gtkrc-2.0";
    XDG_DATA_DIRS = "${config.home.profileDirectory}/share:\${XDG_DATA_DIRS}";
  };

  # Set consistent cursor configuration across the system for X11
  home.pointerCursor = {
    name = cursorTheme.name;
    package = pkgs.bibata-cursors;
    size = cursorTheme.size;
    gtk.enable = true;
    x11.enable = true;
  };

  # Configure GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Everblush";
      package = inputs.everblush-gtk.packages.${pkgs.system}.default;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = cursorTheme.name;
      package = pkgs.bibata-cursors;
      size = cursorTheme.size;
    };
    gtk2.extraConfig = ''
      gtk-theme-name="Everblush"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-cursor-theme-name="${cursorTheme.name}"
      gtk-cursor-theme-size=${toString cursorTheme.size}
      gtk-button-images=0
      gtk-menu-images=0
      gtk-enable-event-sounds=0
      gtk-enable-input-feedback-sounds=0
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
      gtk-application-prefer-dark-theme=1
    '';
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=${cursorTheme.name}
        gtk-cursor-theme-size=${toString cursorTheme.size}
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=${cursorTheme.name}
        gtk-cursor-theme-size=${toString cursorTheme.size}
      '';
    };
  };

  # Configure Wofi application launcher with theme
  programs.wofi = {
    enable = true;
    settings = {
      width = 500;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
    };
    style = ''
      window {
        background-color: ${colors.background};
        color: ${colors.foreground};
        border: 2px solid ${colors.blue};
        border-radius: 8px;
      }

      #input {
        border: 2px solid ${colors.black};
        background-color: ${colors.brightBlack};
        color: ${colors.foreground};
        border-radius: 4px;
        margin: 4px;
        padding: 8px;
      }

      #outer-box {
        margin: 10px;
      }

      #entry:selected {
        background-color: ${colors.blue};
        color: ${colors.background};
        border-radius: 4px;
      }
    '';
  };

  # Explicit GTK settings files
  xdg.configFile = {
    # Hyprcursor configuration
    "hyprcursor/hyprcursor.toml".text = ''
      theme = "${cursorTheme.name}"
      size = ${toString cursorTheme.size}
    '';

    # Hyprland cursor config
    "hypr/cursor.conf".text = ''
      env = XCURSOR_SIZE,${toString cursorTheme.size}
      env = XCURSOR_THEME,${cursorTheme.name}
    '';

    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-cursor-theme-name=${cursorTheme.name}
      gtk-cursor-theme-size=${toString cursorTheme.size}
      gtk-theme-name=Everblush
      gtk-icon-theme-name=Papirus-Dark
      gtk-font-name=Sans 10
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=rgb
    '';

    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-cursor-theme-name=${cursorTheme.name}
      gtk-cursor-theme-size=${toString cursorTheme.size}
      gtk-theme-name=Everblush
      gtk-icon-theme-name=Papirus-Dark
      gtk-font-name=Sans 10
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=rgb
    '';

    # Fix for transparency issues in GTK apps
    "gtk-3.0/gtk.css".text = ''
      /* Fix for transparency issues in GTK apps */
      window, dialog, popover, menu {
        background-color: ${colors.background};
        box-shadow: none;
      }

      window.solid-csd, dialog.solid-csd {
        background-color: ${colors.background};
        box-shadow: none;
      }

      .background {
        background-color: ${colors.background};
      }

      /* Fix for some specific apps with transparency issues */
      .titlebar, headerbar {
        background-color: ${colors.black};
        border-color: ${colors.black};
      }

      /* Fix for context menus */
      menu, .menu, .context-menu {
        background-color: ${colors.black};
        border: 1px solid ${colors.cyan};
      }

      /* Additional fixes for popover widgets */
      popover > arrow,
      popover > contents {
        background-color: ${colors.black};
        border: 1px solid ${colors.cyan};
      }
    '';

    # Apply the same fixes for GTK-4
    "gtk-4.0/gtk.css".text = ''
      /* Fix for transparency issues in GTK apps */
      window, dialog, popover, menu {
        background-color: ${colors.background};
        box-shadow: none;
      }

      window.solid-csd, dialog.solid-csd {
        background-color: ${colors.background};
        box-shadow: none;
      }

      .background {
        background-color: ${colors.background};
      }

      /* Fix for some specific apps with transparency issues */
      .titlebar, headerbar {
        background-color: ${colors.black};
        border-color: ${colors.black};
      }

      /* Fix for context menus */
      menu, .menu, .context-menu {
        background-color: ${colors.black};
        border: 1px solid ${colors.cyan};
      }

      /* Additional fixes for popover widgets */
      popover > arrow,
      popover > contents {
        background-color: ${colors.black};
        border: 1px solid ${colors.cyan};
      }
    '';
  };

  # Add the fix scripts to the user's PATH via home.packages
  home.packages = with pkgs; [
    # Our custom script packages
    gtkTransparencyFix
    cursorFix

    # Theme dependencies
    gtk-engine-murrine
    gtk_engines

    # Icon theme
    papirus-icon-theme

    # Cursor theme
    apple-cursor
    bibata-cursors

    # GTK configuration tools
    dconf
    gnome-themes-extra

    # Add xorg utils for cursor settings
    xorg.xcursorgen
    xorg.xrdb
  ];

  # Automatic activation hook to apply fixes
  home.activation.fixGtkAndCursor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Run our scripts after configuration is written
    echo "Applying GTK transparency fixes..."
    $DRY_RUN_CMD ${gtkTransparencyFix}/bin/fix-gtk-transparency

    echo "Setting up cursor theme..."
    $DRY_RUN_CMD ${cursorFix}/bin/fix-cursor
  '';
}
