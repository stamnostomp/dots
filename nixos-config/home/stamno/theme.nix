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
  };

  # Create a simpler cursor fix script
  home.file.".local/bin/fix-cursor.sh" = {
    executable = true;
    text = ''
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
    '';
  };

  # Add theme-related packages
  home.packages = with pkgs; [
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
}
