# modules/home/desktop/hyprland.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Import colors from the theme module
  # FIXED: Direct import that avoids relative path issues
  colorsDef = import ../../../modules/theme-colors.nix;
  colors = colorsDef.colors;

  # Cursor theme from the central theme module
  cursorTheme = colorsDef.cursor;
in
{
  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    # UWSM (programs.hyprland.withUWSM) owns the systemd graphical session and
    # environment import, so disable HM's own systemd integration to avoid
    # double-starting graphical-session.target.
    systemd.enable = false;
    xwayland.enable = true;
    # Use settings directly rather than extraConfig
    settings = {
      # Monitor configuration with the fixed positioning
      monitor = [
        #"DP-1,3440x1440@144,1080x0,1"
        "HDMI-A-1,1920x1080@75, 0x0 ,1"
      ];

      # Environment variables - cursor settings
      env = [
        "XCURSOR_SIZE,${toString cursorTheme.size}"
        "XCURSOR_THEME,${cursorTheme.name}"
        "WLR_NO_HARDWARE_CURSORS,1" # Needed for NVIDIA
        "GTK_THEME,Everblush" # Set GTK theme
        "GTK2_RC_FILES,${config.xdg.configHome}/gtk-2.0/gtkrc:${config.home.homeDirectory}/.gtkrc-2.0"
        "XDG_DATA_DIRS,${config.home.profileDirectory}/share:$XDG_DATA_DIRS"
        "QT_QPA_PLATFORMTHEME,gtk3"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];

      # Startup applications
      exec-once = [
        "gnome-keyring-daemon --start --components=secrets"
        "hyprcursor"
        "hyprctl setcursor ${cursorTheme.name} ${toString cursorTheme.size}"
        "waybar"
        "dunst"
        "hyprpaper"
        "nm-applet --indicator"
        "blueman-applet"
      ];

      # Input configuration
      input = {
        kb_layout = "us,us";
        kb_variant = ",dvorak";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        resolve_binds_by_sym = true;
        follow_mouse = 1;
        sensitivity = 0.0;
        touchpad = {
          natural_scroll = false;
        };
      };

      # Appearance
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        # Fix the color format for Hyprland
        "col.active_border" = "rgba(6cbfbfee)";
        "col.inactive_border" = "rgba(b3b9b8aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      # Decoration settings
      decoration = {
        rounding = 0;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout settings
      dwindle = {
        preserve_split = true;
      };

      # Gestures

      # Window rules
      windowrule = [
        # Your window rules here
      ];

      # Keybindings
      "$mod" = "SUPER";

      # Keybinds
      bind = [
        # Terminal
        "$mod, Return, exec, alacritty"

        # Program launcher
        "$mod, space, exec, wofi --show drun"
        "$mod ALT, t, exec, wofi --show window"
        "$mod, r, exec, wofi --show run"

        # Power menu
        "$mod SHIFT, p, exec, wlogout"

        # Emacs
        "$mod, e, exec, emacsclient -c"

        # Web browser
        "$mod, w, exec, firefox"

        # File Manager
        "$mod, m, exec, pcmanfm"

        # Audio mixer
        "$mod, p, exec, alacritty -e pulsemixer"

        # Bluetooth manager
        "$mod, b, exec, alacritty -e bluetui"

        # Waybar reload
        "$mod SHIFT, w, exec, killall waybar && waybar &"

        # emacse
        "$mod SHIFT, semicolon, exec, emacsclient -e '(emacs-everywhere)'"

        # Close window
        "$mod, q, killactive"

        # Quit/restart Hyprland
        "$mod ALT, q, exit"
        "$mod ALT, r, exec, hyprctl reload"

        # Screenshots
        "$mod SHIFT, s, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast save area"
        ", Print, exec, grimblast copy area"

        # Fullscreen
        "$mod, f, fullscreen"

        # Window states
        "$mod, t, pseudo"
        "$mod SHIFT, t, layoutmsg, togglesplit"
        "$mod, s, togglefloating"

        # Focus windows
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # Move windows
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scroll through workspaces
        "$mod, bracketleft, workspace, e-1"
        "$mod, bracketright, workspace, e+1"

        # Resize windows with keyboard
        "$mod ALT, h, resizeactive, -20 0"
        "$mod ALT, j, resizeactive, 0 20"
        "$mod ALT, k, resizeactive, 0 -20"
        "$mod ALT, l, resizeactive, 20 0"

        # Move floating windows with arrow keys
        "$mod, Left, moveactive, -20 0"
        "$mod, Down, moveactive, 0 20"
        "$mod, Up, moveactive, 0 -20"
        "$mod, Right, moveactive, 20 0"

        # Volume keys
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        # Backlight controls
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

        # Keyboard layout switching
        "$mod ALT, space, exec, hyprctl switchxkblayout all next"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Additional settings
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };
    };

    # Use extraConfig for the color settings in the correct format
    extraConfig = ''
      # Border colors
      general {
        col.active_border = rgb(6cbfbf)
        col.inactive_border = rgb(b3b9b8)
      }
    '';
  };

  # Set up configuration files for Hyprland
  xdg.configFile = {
    # Hyprcursor configuration
    "hyprcursor/hyprcursor.toml".text = ''
      theme = "${cursorTheme.name}"
      size = ${toString cursorTheme.size}
    '';

    # Hyprpaper config
    "hypr/hyprpaper.conf".text = ''
      preload = ~/.config/hypr/wallpaper.png
      wallpaper = DP-1,~/.config/hypr/wallpaper.png
      wallpaper = HDMI-A-1,~/.config/hypr/wallpaper.png
      splash = false
    '';

    # Additional Hyprland config for cursor
    "hypr/cursor.conf".text = ''
      env = XCURSOR_SIZE,${toString cursorTheme.size}
      env = XCURSOR_THEME,${cursorTheme.name}
    '';
  };

  # Create a direct script to fix cursor on hyprland startup
  home.file.".local/bin/fix-cursor.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Set cursor theme
      export XCURSOR_THEME="${cursorTheme.name}"
      export XCURSOR_SIZE="${toString cursorTheme.size}"

      # Find cursor theme in nix store
      CURSOR_THEME_PATH=$(find /nix/store -name "${cursorTheme.name}" -type d -path "*/share/icons/*" | grep -v "\.icons" | head -n 1)

      # Create symlinks if not already exist
      if [ -n "$CURSOR_THEME_PATH" ]; then
        mkdir -p $HOME/.icons
        mkdir -p $HOME/.local/share/icons
        ln -sf $CURSOR_THEME_PATH $HOME/.icons/
        ln -sf $CURSOR_THEME_PATH $HOME/.local/share/icons/
      else
        # Fallback to package
        ln -sf ${pkgs.apple-cursor}/share/icons/${cursorTheme.name} $HOME/.icons/
        ln -sf ${pkgs.apple-cursor}/share/icons/${cursorTheme.name} $HOME/.local/share/icons/
      fi

      # Set cursor with hyprctl
      hyprctl setcursor "${cursorTheme.name}" "${toString cursorTheme.size}"

      # Update Hyprland config
      echo "env = XCURSOR_SIZE,${toString cursorTheme.size}" > $HOME/.config/hypr/cursor.conf
      echo "env = XCURSOR_THEME,${cursorTheme.name}" >> $HOME/.config/hypr/cursor.conf
    '';
  };

  # Add required packages for Hyprland
  home.packages = with pkgs; [
    # Cursor packages
    hyprcursor
    apple-cursor

    # Wayland utilities
    hyprpaper
    wl-clipboard
    grim
    slurp
    grimblast
    wlr-randr
    wlogout
    swaylock-effects

    # Screen brightness
    brightnessctl

    # System tray applications
    networkmanagerapplet
    blueman

    # Keyring for secrets management
    gnome-keyring

    # XDG portal
    xdg-desktop-portal-hyprland
  ];
}
