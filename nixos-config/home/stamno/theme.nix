# home/stamno/theme.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Theme configuration - using Adwaita-dark GTK theme with Everblush colors
  theme = {
    name = "Adwaita-dark"; # Adwaita-dark is the stable GTK theme
    package = pkgs.gnome-themes-extra; # Corrected package path
    cursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    icons = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    # Everblush colors
    colors = {
      background = "#141b1e";
      foreground = "#dadada";
      cursor = "#dadada";
      black = "#232a2d";
      red = "#e57474";
      green = "#8ccf7e";
      yellow = "#e5c76b";
      blue = "#67b0e8";
      magenta = "#c47fd5";
      cyan = "#6cbfbf";
      white = "#b3b9b8";
      brightBlack = "#2d3437";
      brightRed = "#ef7e7e";
      brightGreen = "#96d988";
      brightYellow = "#f4d67a";
      brightBlue = "#71baf2";
      brightMagenta = "#ce89df";
      brightCyan = "#67cbe7";
      brightWhite = "#bdc3c2";
      waybarbg = "#232a2d"; # Using the black color as a lighter background
    };
    # Waybar font that we'll reuse for Wofi
    font = "Cozette, JetBrainsMono Nerd Font, Siji, FontAwesome";
    fontSize = "13px";
  };

  # Helper function to convert hex to rgba
  hexToRgba =
    hex: opacity:
    let
      r = builtins.substring 1 2 hex;
      g = builtins.substring 3 2 hex;
      b = builtins.substring 5 2 hex;

      # Convert hex to decimal
      hexToDec =
        hex:
        let
          chars = lib.stringToCharacters hex;
          value =
            c:
            let
              v = builtins.substring 0 1 (lib.toLower c);
            in
            if v == "a" then
              10
            else if v == "b" then
              11
            else if v == "c" then
              12
            else if v == "d" then
              13
            else if v == "e" then
              14
            else if v == "f" then
              15
            else
              lib.toInt v;
        in
        (value (builtins.elemAt chars 0)) * 16 + (value (builtins.elemAt chars 1));

      # Convert to rgba format
      dec_r = hexToDec r;
      dec_g = hexToDec g;
      dec_b = hexToDec b;
    in
    "rgba(${toString dec_r}, ${toString dec_g}, ${toString dec_b}, ${toString opacity})";

  # Create a script derivation for cursor fix that runs AFTER home-manager
  # This instead of creating files that conflict with home-manager
  cursorFix = pkgs.writeScriptBin "fix-cursor" ''
    #!/usr/bin/env bash

    # Set cursor theme
    export XCURSOR_THEME="${theme.cursor.name}"
    export XCURSOR_SIZE="${toString theme.cursor.size}"

    # Do NOT create these directories or symlinks - they are managed by Home Manager now
    # Instead, just ensure the cursor is properly set in Hyprland
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

  # Create a script to set Papirus folder color to match Everblush cyan
  papirusFolderColor = pkgs.writeScriptBin "set-papirus-folder-color" ''
    #!/usr/bin/env bash

    # Check if papirus-folders is installed
    if ! command -v papirus-folders &> /dev/null; then
      echo "papirus-folders not found. Installing..."
      ${pkgs.papirus-folders}/bin/papirus-folders -h &> /dev/null
    fi

    # Set the folder color to cyan (matching Everblush cyan)
    ${pkgs.papirus-folders}/bin/papirus-folders -C cyan --theme Papirus-Dark

    echo "Papirus folder color set to cyan for Papirus-Dark theme"
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
  # THIS IS THE IMPORTANT PART - LET HOME MANAGER HANDLE THE CURSOR THEME
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
        gtk-primary-button-warps-slider=false
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
        gtk-cursor-theme-name=${theme.cursor.name}
        gtk-cursor-theme-size=${toString theme.cursor.size}
        gtk-primary-button-warps-slider=false
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
      * {
        font-family: ${theme.font};
        font-size: ${theme.fontSize};
        border: none;
        border-radius: 0;
      }

      window {
        background-color: ${theme.colors.background};
        color: ${theme.colors.foreground};
        border: 2px solid ${theme.colors.cyan};
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

      #text:selected {
        color: ${theme.colors.background};
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
      gtk-primary-button-warps-slider=false
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
      gtk-primary-button-warps-slider=false
    '';

    # Everblush for Alacritty
    "alacritty/everblush.toml".text = ''
      # Everblush theme for Alacritty

      [colors.primary]
      background = "${theme.colors.background}"
      foreground = "${theme.colors.foreground}"

      [colors.cursor]
      text = "${theme.colors.background}"
      cursor = "${theme.colors.foreground}"

      [colors.normal]
      black = "${theme.colors.black}"
      red = "${theme.colors.red}"
      green = "${theme.colors.green}"
      yellow = "${theme.colors.yellow}"
      blue = "${theme.colors.blue}"
      magenta = "${theme.colors.magenta}"
      cyan = "${theme.colors.cyan}"
      white = "${theme.colors.white}"

      [colors.bright]
      black = "${theme.colors.brightBlack}"
      red = "${theme.colors.brightRed}"
      green = "${theme.colors.brightGreen}"
      yellow = "${theme.colors.brightYellow}"
      blue = "${theme.colors.brightBlue}"
      magenta = "${theme.colors.brightMagenta}"
      cyan = "${theme.colors.brightCyan}"
      white = "${theme.colors.brightWhite}"
    '';

    # Set Alacritty to use the Everblush theme by default
    "alacritty/alacritty.toml".text = ''
      import = ["~/.config/alacritty/everblush.toml"]
    '';

    # Kitty themes
    "kitty/everblush.conf".text = ''
      # Everblush theme for Kitty
      foreground              ${theme.colors.foreground}
      background              ${theme.colors.background}
      selection_foreground    ${theme.colors.background}
      selection_background    ${theme.colors.white}

      cursor                  ${theme.colors.foreground}
      cursor_text_color       ${theme.colors.background}

      # Black
      color0                  ${theme.colors.black}
      color8                  ${theme.colors.brightBlack}

      # Red
      color1                  ${theme.colors.red}
      color9                  ${theme.colors.brightRed}

      # Green
      color2                  ${theme.colors.green}
      color10                 ${theme.colors.brightGreen}

      # Yellow
      color3                  ${theme.colors.yellow}
      color11                 ${theme.colors.brightYellow}

      # Blue
      color4                  ${theme.colors.blue}
      color12                 ${theme.colors.brightBlue}

      # Magenta
      color5                  ${theme.colors.magenta}
      color13                 ${theme.colors.brightMagenta}

      # Cyan
      color6                  ${theme.colors.cyan}
      color14                 ${theme.colors.brightCyan}

      # White
      color7                  ${theme.colors.white}
      color15                 ${theme.colors.brightWhite}

      # Tabs
      active_tab_foreground   ${theme.colors.background}
      active_tab_background   ${theme.colors.cyan}
      inactive_tab_foreground ${theme.colors.white}
      inactive_tab_background ${theme.colors.black}
      tab_bar_background      ${theme.colors.background}

      # Windows
      active_border_color     ${theme.colors.cyan}
      inactive_border_color   ${theme.colors.black}
    '';

    # Make kitty use the theme by default
    "kitty/kitty.conf".text = ''
      include ~/.config/kitty/everblush.conf
    '';
  };

  # Update Hyprland configuration with the theme colors (using fixed format)
  wayland.windowManager.hyprland.extraConfig = ''
    # Everblush Theme Colors
    general {
        col.active_border = rgba(6cbfbfee)
        col.inactive_border = rgba(b3b9b8aa)
    }

    # Everblush group border colors
    group {
        col.border_active = rgba(6cbfbfee)
        col.border_inactive = rgba(b3b9b8aa)
        col.border_locked_active = rgba(c47fd5ee)
        col.border_locked_inactive = rgba(2d3437aa)
    }
  '';

  # Generate wallpaper with the Everblush colors - FIXED version without text annotation
  home.activation.generateWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/hypr
    # Create a simple gradient wallpaper without text annotation
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 gradient:${theme.colors.background}-${theme.colors.black} ~/.config/hypr/wallpaper.png
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

    # GTK theme - corrected path
    gnome-themes-extra

    # Icon theme
    papirus-icon-theme
    papirus-folders # This has the CLI tool to change folder colors

    # Cursor theme - HOME MANAGER WILL HANDLE THE SYMLINKS
    theme.cursor.package

    # GTK configuration tools
    dconf
    gnome-themes-extra

    # Add xorg utils for cursor settings
    xorg.xcursorgen
    xorg.xrdb
  ];

  # Activation hooks to ensure themes are applied
  # IMPORTANT: This now runs AFTER Home Manager has set up the cursor theme files
  home.activation = {
    setupTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Set GTK theme using gsettings (works for both GNOME and XFCE)
      # Only run if gsettings is available (dconf/gsettings work in XFCE too)
      if command -v gsettings >/dev/null 2>&1; then
        # Try to set GNOME settings (won't error if schema doesn't exist)
        if gsettings list-schemas | grep -q "org.gnome.desktop.interface"; then
          $DRY_RUN_CMD gsettings set org.gnome.desktop.interface gtk-theme "${theme.name}" 2>/dev/null || true
          $DRY_RUN_CMD gsettings set org.gnome.desktop.interface icon-theme "${theme.icons.name}" 2>/dev/null || true
          $DRY_RUN_CMD gsettings set org.gnome.desktop.interface cursor-theme "${theme.cursor.name}" 2>/dev/null || true
          $DRY_RUN_CMD gsettings set org.gnome.desktop.interface cursor-size ${toString theme.cursor.size} 2>/dev/null || true
        fi

        # XFCE-specific settings
        if command -v xfconf-query >/dev/null 2>&1; then
          $DRY_RUN_CMD xfconf-query -c xsettings -p /Net/ThemeName -s "${theme.name}" 2>/dev/null || true
          $DRY_RUN_CMD xfconf-query -c xsettings -p /Net/IconThemeName -s "${theme.icons.name}" 2>/dev/null || true
          $DRY_RUN_CMD xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "${theme.cursor.name}" 2>/dev/null || true
          $DRY_RUN_CMD xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s ${toString theme.cursor.size} 2>/dev/null || true
        fi
      fi

      # Run cursor fix script - but this no longer creates symlinks that conflict
      $DRY_RUN_CMD ${cursorFix}/bin/fix-cursor

      # Set Papirus folder color
      if [ -x "${pkgs.papirus-folders}/bin/papirus-folders" ]; then
        $DRY_RUN_CMD ${papirusFolderColor}/bin/set-papirus-folder-color
      fi
    '';
  };
}
