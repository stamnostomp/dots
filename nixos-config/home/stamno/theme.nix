# Create a modified theme.nix file

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Theme configuration - change just this section to switch themes
  theme = {
    name = "Tokyonight-Dark-B";
    package = pkgs.tokyo-night-gtk;
    cursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 20;
    };
    icons = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    colors = {
      # Tokyo Night colors
      background = "#1a1b26";
      foreground = "#c0caf5";
      black = "#15161e";
      brightBlack = "#414868";
      red = "#f7768e";
      brightRed = "#f7768e";
      green = "#9ece6a";
      brightGreen = "#9ece6a";
      yellow = "#e0af68";
      brightYellow = "#e0af68";
      blue = "#7aa2f7";
      brightBlue = "#7aa2f7";
      magenta = "#bb9af7";
      brightMagenta = "#bb9af7";
      cyan = "#7dcfff";
      brightCyan = "#7dcfff";
      white = "#a9b1d6";
      brightWhite = "#c0caf5";
      waybarbg = "#24283b"; # Slightly lighter background for waybar
    };
  };

  # Create a script derivation for cursor fix
  cursorFix = pkgs.writeScriptBin "fix-cursor" ''
    #!/usr/bin/env bash

    # Set cursor theme
    export XCURSOR_THEME="${theme.cursor.name}"
    export XCURSOR_SIZE="${toString theme.cursor.size}"

    # Create necessary directories
    mkdir -p $HOME/.icons
    mkdir -p $HOME/.local/share/icons

    # Create symbolic links to cursor theme
    ln -sf ${theme.cursor.package}/share/icons/${theme.cursor.name} $HOME/.icons/
    ln -sf ${theme.cursor.package}/share/icons/${theme.cursor.name} $HOME/.local/share/icons/

    # Explicitly set cursor with hyprctl if Hyprland is running
    if command -v hyprctl &>/dev/null && pgrep -x Hyprland &>/dev/null; then
      hyprctl setcursor "${theme.cursor.name}" "${toString theme.cursor.size}"
    fi

    echo "Cursor theme set to ${theme.cursor.name} with size ${toString theme.cursor.size}"
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

    echo "All custom GTK fixes have been cleaned up. You should log out and back in for the changes to take effect."
  '';

  # Create a script to set Papirus folder color
  papirusFolderColor = pkgs.writeScriptBin "set-papirus-folder-color" ''
    #!/usr/bin/env bash

    # Check if papirus-folders is installed
    if ! command -v papirus-folders &> /dev/null; then
      echo "papirus-folders not found. Installing..."
      ${pkgs.papirus-folders}/bin/papirus-folders -h &> /dev/null
    fi

    # Set the folder color to blue
    ${pkgs.papirus-folders}/bin/papirus-folders -C blue --theme Papirus-Dark

    echo "Papirus folder color set to blue for Papirus-Dark theme"
  '';
in
{
  # Set cursor environment variables consistently
  home.sessionVariables = {
    XCURSOR_PATH = "${config.home.profileDirectory}/share/icons:${theme.cursor.package}/share/icons";
    XCURSOR_THEME = theme.cursor.name;
    XCURSOR_SIZE = toString theme.cursor.size;
    GTK_THEME = theme.name;
    # Use mkForce to override the conflicting definition
    GTK2_RC_FILES = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc:${config.home.homeDirectory}/.gtkrc-2.0";
    XDG_DATA_DIRS = "${config.home.profileDirectory}/share:\${XDG_DATA_DIRS}";
  };

  # Set consistent cursor configuration across the system for X11
  home.pointerCursor = {
    name = theme.cursor.name;
    package = theme.cursor.package;
    size = theme.cursor.size;
    gtk.enable = true;
    x11.enable = true;
  };

  # Configure GTK theme
  gtk = {
    enable = true;
    theme = {
      name = theme.name;
      package = theme.package;
    };
    iconTheme = {
      name = theme.icons.name;
      package = theme.icons.package;
    };
    cursorTheme = {
      name = theme.cursor.name;
      package = theme.cursor.package;
      size = theme.cursor.size;
    };
    gtk2.extraConfig = ''
      gtk-theme-name="${theme.name}"
      gtk-icon-theme-name="${theme.icons.name}"
      gtk-cursor-theme-name="${theme.cursor.name}"
      gtk-cursor-theme-size=${toString theme.cursor.size}
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
        gtk-cursor-theme-name=${theme.cursor.name}
        gtk-cursor-theme-size=${toString theme.cursor.size}
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=${theme.cursor.name}
        gtk-cursor-theme-size=${toString theme.cursor.size}
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
        background-color: ${theme.colors.background};
        color: ${theme.colors.foreground};
        border: 2px solid ${theme.colors.blue};
        border-radius: 8px;
      }

      #input {
        border: 2px solid ${theme.colors.black};
        background-color: ${theme.colors.brightBlack};
        color: ${theme.colors.foreground};
        border-radius: 4px;
        margin: 4px;
        padding: 8px;
      }

      #outer-box {
        margin: 10px;
      }

      #entry:selected {
        background-color: ${theme.colors.blue};
        color: ${theme.colors.background};
        border-radius: 4px;
      }
    '';
  };

  # Explicit GTK settings files
  xdg.configFile = {
    # Hyprcursor configuration
    "hyprcursor/hyprcursor.toml".text = ''
      theme = "${theme.cursor.name}"
      size = ${toString theme.cursor.size}
    '';

    # Hyprland cursor config
    "hypr/cursor.conf".text = ''
      env = XCURSOR_SIZE,${toString theme.cursor.size}
      env = XCURSOR_THEME,${theme.cursor.name}
    '';

    # Updated GTK settings with theme variables
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-cursor-theme-name=${theme.cursor.name}
      gtk-cursor-theme-size=${toString theme.cursor.size}
      gtk-theme-name=${theme.name}
      gtk-icon-theme-name=${theme.icons.name}
      gtk-font-name=Sans 10
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=rgb
    '';

    # Same for GTK4
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-cursor-theme-name=${theme.cursor.name}
      gtk-cursor-theme-size=${toString theme.cursor.size}
      gtk-theme-name=${theme.name}
      gtk-icon-theme-name=${theme.icons.name}
      gtk-font-name=Sans 10
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=rgb
    '';

    # Update waybar style to use the new theme colors
    "waybar/style.css".text = ''
      * {
          font-family: "Cozette", "JetBrainsMono Nerd Font", "Siji", "FontAwesome";
          font-size: 13px;
          border: none;
          border-radius: 0;
      }

      window#waybar {
          background-color: ${theme.colors.waybarbg};
          color: ${theme.colors.foreground};
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: ${theme.colors.foreground};
      }

      #workspaces button.active {
          background-color: ${theme.colors.black};
          color: ${theme.colors.foreground};
          border-bottom: 2px solid ${theme.colors.blue};
      }

      #workspaces button:hover {
          background: rgba(50, 48, 47, 0.5);
      }

      #window {
          padding: 0 10px;
      }

      #cpu {
          color: ${theme.colors.blue};
      }

      #memory {
          color: ${theme.colors.magenta};
      }

      #disk {
          color: ${theme.colors.cyan};
      }

      #pulseaudio {
          color: ${theme.colors.yellow};
      }

      #clock {
          color: ${theme.colors.brightCyan};
      }

      /* Fix for custom separators */
      #custom-left {
          font-size: 20px;
          color: ${theme.colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      #custom-right {
          font-size: 20px;
          color: ${theme.colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      /* Module styling with consistent background */
      #cpu, #memory, #disk, #pulseaudio, #battery, #network, #clock {
          padding: 0 10px;
          margin: 0;
          background-color: ${theme.colors.waybarbg};
      }

      #workspaces {
          background-color: ${theme.colors.waybarbg};
          padding: 0 5px;
          margin: 0;
      }

      #window {
          background-color: ${theme.colors.waybarbg};
          margin: 0;
      }

      /* Add styling for tray to match */
      #tray {
          background-color: ${theme.colors.waybarbg};
          padding: 0 10px;
          margin-right: 5px;
      }

      /* Tooltip styling */
      tooltip {
          background-color: ${theme.colors.background};
          border: 1px solid ${theme.colors.blue};
          border-radius: 2px;
      }

      tooltip label {
          color: ${theme.colors.foreground};
      }
    '';
  };

  # Update Hyprland configuration with the theme colors
  wayland.windowManager.hyprland.extraConfig = ''
    # Theme colors
    general {
        col.active_border = rgba(${theme.colors.blue}ee)
        col.inactive_border = rgba(${theme.colors.white}aa)
    }
  '';

  # Generate wallpaper with the new background color
  home.activation.generateWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/hypr
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 "xc:${theme.colors.background}" ~/.config/hypr/wallpaper.png
  '';

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
    theme.cursor.package

    # GTK configuration tools
    dconf
    gnome-themes-extra

    # Add xorg utils for cursor settings
    xorg.xcursorgen
    xorg.xrdb
  ];

  # Activation hooks to ensure themes are applied
  home.activation = {
    setupTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Ensure GTK theme is properly set
      if command -v gsettings >/dev/null 2>&1; then
        $DRY_RUN_CMD gsettings set org.gnome.desktop.interface gtk-theme "${theme.name}"
        $DRY_RUN_CMD gsettings set org.gnome.desktop.interface icon-theme "${theme.icons.name}"
        $DRY_RUN_CMD gsettings set org.gnome.desktop.interface cursor-theme "${theme.cursor.name}"
        $DRY_RUN_CMD gsettings set org.gnome.desktop.interface cursor-size ${toString theme.cursor.size}
      fi

      # Run cursor fix script
      $DRY_RUN_CMD ${cursorFix}/bin/fix-cursor

      # Set Papirus folder color
      if [ -x "${pkgs.papirus-folders}/bin/papirus-folders" ]; then
        $DRY_RUN_CMD ${papirusFolderColor}/bin/set-papirus-folder-color
      fi
    '';
  };
}
