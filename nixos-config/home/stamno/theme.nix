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

  # Create a script to clean up previous GTK fixes
  cleanupGtkFixes = pkgs.writeScriptBin "cleanup-gtk-fixes" ''
        #!/usr/bin/env bash

        # Define paths to clean up
        GTK3_CSS="$HOME/.config/gtk-3.0/gtk.css"
        GTK4_CSS="$HOME/.config/gtk-4.0/gtk.css"
        GTK3_FLATPAK="$HOME/.config/gtk-3.0/flatpak-overrides/gtk.css"
        GTK4_FLATPAK="$HOME/.config/gtk-4.0/flatpak-overrides/gtk.css"
        STEAM_CSS="$HOME/.local/share/Steam/skins/Everblush/resource/styles.css"
        STEAM_LAYOUT="$HOME/.local/share/Steam/skins/Everblush/resource/layout.css"

        # Function to reset a CSS file
        reset_css() {
          local file="$1"
          if [ -f "$file" ]; then
            echo "Removing custom CSS from $file"
            rm -f "$file"
          fi
        }

        # Reset all CSS files
        reset_css "$GTK3_CSS"
        reset_css "$GTK4_CSS"
        reset_css "$GTK3_FLATPAK"
        reset_css "$GTK4_FLATPAK"
        reset_css "$STEAM_CSS"
        reset_css "$STEAM_LAYOUT"

        # Remove Steam skin directory if empty
        if [ -d "$(dirname "$STEAM_CSS")" ] && [ -z "$(ls -A "$(dirname "$STEAM_CSS")")" ]; then
          rm -rf "$(dirname "$(dirname "$STEAM_CSS")")"
          echo "Removed empty Steam skin directory"
        fi

        # Create minimal GTK CSS for both GTK3 and GTK4 with just the background color
        mkdir -p "$(dirname "$GTK3_CSS")"
        cat > "$GTK3_CSS" << EOF
    /* Minimal CSS file - only contains necessary settings */
    window.background {
      background-color: #141b1e;
    }
    EOF

        mkdir -p "$(dirname "$GTK4_CSS")"
        cat > "$GTK4_CSS" << EOF
    /* Minimal CSS file - only contains necessary settings */
    window.background {
      background-color: #141b1e;
    }
    EOF

        echo "All custom GTK fixes have been cleaned up. You should log out and back in for the changes to take effect."
  '';

  # Create a script to set Papirus folder color to blue-grey
  papirusFolderColor = pkgs.writeScriptBin "set-papirus-folder-color" ''
    #!/usr/bin/env bash

    # Check if papirus-folders is installed
    if ! command -v papirus-folders &> /dev/null; then
      echo "papirus-folders not found. Installing..."
      ${pkgs.papirus-folders}/bin/papirus-folders -h &> /dev/null
    fi

    # Set the folder color to blue-grey
    ${pkgs.papirus-folders}/bin/papirus-folders -C bluegrey --theme Papirus-Dark

    echo "Papirus folder color set to blue-grey for Papirus-Dark theme"
  '';
in
{
  # Set cursor environment variables consistently
  home.sessionVariables = {
    XCURSOR_PATH = "${config.home.profileDirectory}/share/icons:${pkgs.apple-cursor}/share/icons";
    XCURSOR_THEME = cursorTheme.name;
    XCURSOR_SIZE = toString cursorTheme.size;
    GTK_THEME = "Tokyonight-Dark-B";
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
      name = "Tokyonight-Dark-B";
      package = pkgs.tokyo-night-gtk;
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
      gtk-theme-name="Tokyonight-Dark-B"
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
      gtk-theme-name="Tokyonight-Dark-B"
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
      gtk-theme-name="Tokyonight-Dark-B"
      gtk-icon-theme-name=Papirus-Dark
      gtk-font-name=Sans 10
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=rgb
    '';

    # Waybar style for fixing black bars
    "waybar/style.css".text = ''
      * {
          font-family: "Cozette", "JetBrainsMono Nerd Font", "Siji", "FontAwesome";
          font-size: 13px;
          border: none;
          border-radius: 0;
      }

      window#waybar {
          background-color: ${colors.waybarbg};
          color: #dadada;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #dadada;
      }

      #workspaces button.active {
          background-color: #32302f;
          color: #dadada;
          border-bottom: 2px solid #427b58;
      }

      #workspaces button:hover {
          background: rgba(50, 48, 47, 0.5);
      }

      #window {
          padding: 0 10px;
      }

      #cpu {
          color: ${colors.blue};
      }

      #memory {
          color: ${colors.magenta};
      }

      #disk {
          color: ${colors.cyan};
      }

      #pulseaudio {
          color: ${colors.yellow};
      }

      #clock {
          color: ${colors.brightCyan};
      }

      /* Fix for custom separators */
      #custom-left {
          font-size: 20px;
          color: ${colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      #custom-right {
          font-size: 20px;
          color: ${colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      /* Fix spacing between modules */
      #workspaces {
          background-color: ${colors.waybarbg};
          padding: 0 5px;
          margin: 0;
      }

      #window {
          background-color: ${colors.waybarbg};
          margin: 0;
      }

      /* Module styling with consistent background */
      #cpu, #memory, #disk, #pulseaudio, #battery, #network, #clock {
          padding: 0 10px;
          margin: 0;
          background-color: ${colors.waybarbg};
      }

      /* Fix for waybar spacing */
      box {
          padding: 0;
          margin: 0;
          background-color: transparent;
      }

      /* Add styling for tray to match */
      #tray {
          background-color: ${colors.waybarbg};
          padding: 0 10px;
          margin-right: 5px;
      }

      /* Specific fix for gaps between modules */
      .modules-left, .modules-center, .modules-right {
          background-color: ${colors.waybarbg};
      }

      /* Tooltip styling */
      tooltip {
          background-color: ${colors.background};
          border: 1px solid ${colors.blue};
          border-radius: 2px;
      }

      tooltip label {
          color: ${colors.foreground};
      }
    '';

    "gtk-3.0/gtk.css".text = ''
      /* GTK Selection Highlighting Fix for Everblush Theme */

      /* Generic selection highlight rules */
      ::-moz-selection {
        background-color: #67b0e8 !important; /* Using the blue from your theme */
        color: #141b1e !important;           /* Using your background color for contrast */
      }

      ::selection {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      /* GTK specific selection highlight */
      *:selected,
      *:focus:selected {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      /* Text view and other widget selection */
      textview text:selected,
      textview text:selected:focus,
      textview text selection,
      entry selection,
      label selection,
      .view:selected,
      .view:selected:focus,
      .view text:selected,
      iconview:selected,
      iconview:selected:focus,
      flowbox flowboxchild:selected,
      entry:selected,
      modelbutton.flat:selected,
      treeview.view:selected,
      treeview.view:selected:focus,
      row:selected,
      calendar:selected,
      .gedit-document-panel-document-row:selected {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      /* For Thunar/PCManFM specific fixes */
      .thunar .view:selected,
      .pcmanfm .view:selected,
      .thunar .sidebar .view:selected,
      .pcmanfm .sidebar .view:selected {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      /* File browsers selection */
      filechooser .view:selected,
      filechooser .view:selected:focus {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      /* Terminal selection - often needs special handling */
      vte-terminal selection {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }
    '';

    # Also add for GTK4 applications
    "gtk-4.0/gtk.css".text = ''
      /* GTK4 Selection Highlighting Fix for Everblush Theme */

      /* Generic selection highlight rules */
      ::-moz-selection {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      ::selection {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      /* GTK specific selection highlight */
      *:selected,
      *:focus:selected {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }

      /* Text view and other widget selection */
      textview text:selected,
      textview text:selected:focus,
      textview text selection,
      entry selection,
      label selection,
      .view:selected,
      .view:selected:focus,
      .view text:selected,
      iconview:selected,
      iconview:selected:focus,
      flowbox flowboxchild:selected,
      entry:selected {
        background-color: #67b0e8 !important;
        color: #141b1e !important;
      }
    '';
  };

  # Add scripts and packages
  home.packages = with pkgs; [
    # Our custom script packages
    cursorFix
    papirusFolderColor
    cleanupGtkFixes

    # Theme dependencies
    gtk-engine-murrine
    gtk_engines

    # Icon theme
    papirus-icon-theme
    papirus-folders

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

  # Activation hooks
  home.activation = {
    # Clean up old GTK fixes - runs first
    # Fix cursor
    #fixCursor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # echo "Setting up cursor theme..."
    #$DRY_RUN_CMD ${cursorFix}/bin/fix-cursor
    #'';

    # Set Papirus folder color
    #setPapirusFolderColor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # echo "Setting Papirus folder color to blue-grey..."
    # $DRY_RUN_CMD ${papirusFolderColor}/bin/set-papirus-folder-color
    #'';
  };
}
