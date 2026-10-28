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

  lua = lib.generators.mkLuaInline;
in
{
  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    # Lua config (hyprlang is deprecated since Hyprland 0.55).
    # Generates $XDG_CONFIG_HOME/hypr/hyprland.lua.
    configType = "lua";
    # UWSM (programs.hyprland.withUWSM) owns the systemd graphical session and
    # environment import, so disable HM's own systemd integration to avoid
    # double-starting graphical-session.target.
    systemd.enable = false;
    xwayland.enable = true;
    # Each settings attribute maps to an hl.<name>(...) call in hyprland.lua.
    # See https://wiki.hypr.land/Configuring/Start/ and the
    # home-manager hyprland module docs for the mapping rules.
    settings = {
      # Lua variable for the modifier key, referenced as `mod .. " + ..."`
      # in keybinds below (replaces hyprlang `$mod`).
      mod = {
        _var = "SUPER";
      };

      # Monitor configuration with the fixed positioning
      monitor = [
        #",DP-1,3440x1440@144,1080x0,1"
        #{ output = "DP-1"; mode = "3440x1440@144"; position = "1080x0"; scale = 1; }
        # "HDMI-A-1,1920x1080@75, 0x0 ,1"
        #{ output = "HDMI-A-1"; mode = "1920x1080@75"; position = "0x0"; scale = 1; }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        } # External displays (auto-detect)
      ];

      # Environment variables - cursor settings
      env = [
        { _args = [ "XCURSOR_SIZE" "${toString cursorTheme.size}" ]; }
        { _args = [ "XCURSOR_THEME" cursorTheme.name ]; }
        { _args = [ "WLR_NO_HARDWARE_CURSORS" "1" ]; } # Needed for NVIDIA
        { _args = [ "GTK_THEME" "Everblush" ]; } # Set GTK theme
        { _args = [ "GTK2_RC_FILES" "${config.xdg.configHome}/gtk-2.0/gtkrc:${config.home.homeDirectory}/.gtkrc-2.0" ]; }
        {
          _args = [
            "XDG_DATA_DIRS"
            # Same value as before; $XDG_DATA_DIRS is expanded via Lua
            # instead of relying on hyprlang variable expansion.
            (lua ''"${config.home.profileDirectory}/share:" .. (os.getenv("XDG_DATA_DIRS") or "")'')
          ];
        }
        { _args = [ "QT_QPA_PLATFORMTHEME" "gtk3" ]; }
        { _args = [ "WLR_NO_HARDWARE_CURSORS" "1" ]; }
      ];

      # Startup applications (exec-once equivalent: runs once at startup,
      # not on every `hyprctl reload`, matching previous behavior).
      on = [
        {
          _args = [
            "hyprland.start"
            (lua ''
              function()
                hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
                hl.exec_cmd("hyprcursor")
                hl.exec_cmd("hyprctl setcursor ${cursorTheme.name} ${toString cursorTheme.size}")
                hl.exec_cmd("waybar")
                hl.exec_cmd("dunst")
                hl.exec_cmd("hyprpaper")
                hl.exec_cmd("nm-applet --indicator")
                hl.exec_cmd("blueman-applet")
                hl.exec_cmd("kdeconnect-app")
              end
            '')
          ];
        }
      ];

      # Plain config categories (hl.config({...})).
      config = {
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
          col = {
            active_border = "rgba(6cbfbfee)";
            inactive_border = "rgba(b3b9b8aa)";
          };
          layout = "dwindle";
          resize_on_border = true;
        };

        # Decoration settings
        decoration = {
          rounding = 0;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
        };

        # Master animation switch (curves and per-leaf animations
        # are top-level hl.curve / hl.animation calls below).
        animations = {
          enabled = true;
        };

        # Layout settings
        dwindle = {
          preserve_split = true;
        };

        # Gestures

        # Additional settings
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
        };
      };

      # Animation curve (was: bezier = myBezier, 0.05, 0.9, 0.1, 1.05).
      curve = {
        _args = [
          "myBezier"
          {
            type = "bezier";
            points = [
              [
                0.05
                0.9
              ]
              [
                0.1
                1.05
              ]
            ];
          }
        ];
      };

      # Per-leaf animations (was: animation = windows, 1, 7, myBezier ...).
      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 7;
          bezier = "myBezier";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 7;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 7;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 6;
          bezier = "default";
        }
      ];

      # Window rules (none)
      window_rule = [
        # Your window rules here
      ];

      # Keybindings
      bind = [
        # Terminal
        { _args = [ (lua ''mod .. " + Return"'') (lua ''hl.dsp.exec_cmd("alacritty")'') ]; }

        # Program launcher
        { _args = [ (lua ''mod .. " + space"'') (lua ''hl.dsp.exec_cmd("wofi --show drun")'') ]; }
        { _args = [ (lua ''mod .. " + ALT + t"'') (lua ''hl.dsp.exec_cmd("wofi --show window")'') ]; }
        { _args = [ (lua ''mod .. " + r"'') (lua ''hl.dsp.exec_cmd("wofi --show run")'') ]; }

        # Power menu
        { _args = [ (lua ''mod .. " + SHIFT + p"'') (lua ''hl.dsp.exec_cmd("wlogout")'') ]; }

        # Emacs
        { _args = [ (lua ''mod .. " + e"'') (lua ''hl.dsp.exec_cmd("emacsclient -c")'') ]; }

        # Web browser
        { _args = [ (lua ''mod .. " + w"'') (lua ''hl.dsp.exec_cmd("zen-beta")'') ]; }

        # File Manager
        { _args = [ (lua ''mod .. " + m"'') (lua ''hl.dsp.exec_cmd("pcmanfm")'') ]; }

        # Audio mixer
        { _args = [ (lua ''mod .. " + p"'') (lua ''hl.dsp.exec_cmd("alacritty -e pulsemixer")'') ]; }

        # Bluetooth manager
        { _args = [ (lua ''mod .. " + b"'') (lua ''hl.dsp.exec_cmd("alacritty -e bluetui")'') ]; }

        # Waybar reload
        { _args = [ (lua ''mod .. " + SHIFT + w"'') (lua ''hl.dsp.exec_cmd("killall waybar && waybar &")'') ]; }

        # emacse
        { _args = [ (lua ''mod .. " + SHIFT + semicolon"'') (lua ''hl.dsp.exec_cmd("emacsclient -e '(emacs-everywhere)'")'') ]; }

        # Close window
        { _args = [ (lua ''mod .. " + q"'') (lua ''hl.dsp.window.close()'') ]; }

        # Quit/restart Hyprland
        { _args = [ (lua ''mod .. " + ALT + q"'') (lua ''hl.dsp.exit()'') ]; }
        { _args = [ (lua ''mod .. " + ALT + r"'') (lua ''hl.dsp.exec_cmd("hyprctl reload")'') ]; }

        # Screenshots
        { _args = [ (lua ''mod .. " + SHIFT + s"'') (lua ''hl.dsp.exec_cmd("grimblast copy area")'') ]; }
        { _args = [ "SHIFT + Print" (lua ''hl.dsp.exec_cmd("grimblast save area")'') ]; }
        { _args = [ "Print" (lua ''hl.dsp.exec_cmd("grimblast copy area")'') ]; }

        # Fullscreen
        { _args = [ (lua ''mod .. " + f"'') (lua ''hl.dsp.window.fullscreen()'') ]; }

        # Window states
        { _args = [ (lua ''mod .. " + t"'') (lua ''hl.dsp.window.pseudo()'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + t"'') (lua ''hl.dsp.layout("togglesplit")'') ]; }
        { _args = [ (lua ''mod .. " + s"'') (lua ''hl.dsp.window.float({ action = "toggle" })'') ]; }

        # Focus windows
        { _args = [ (lua ''mod .. " + h"'') (lua ''hl.dsp.focus({ direction = "left" })'') ]; }
        { _args = [ (lua ''mod .. " + j"'') (lua ''hl.dsp.focus({ direction = "down" })'') ]; }
        { _args = [ (lua ''mod .. " + k"'') (lua ''hl.dsp.focus({ direction = "up" })'') ]; }
        { _args = [ (lua ''mod .. " + l"'') (lua ''hl.dsp.focus({ direction = "right" })'') ]; }

        # Move windows
        { _args = [ (lua ''mod .. " + SHIFT + h"'') (lua ''hl.dsp.window.move({ direction = "left" })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + j"'') (lua ''hl.dsp.window.move({ direction = "down" })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + k"'') (lua ''hl.dsp.window.move({ direction = "up" })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + l"'') (lua ''hl.dsp.window.move({ direction = "right" })'') ]; }

        # Switch workspaces
        { _args = [ (lua ''mod .. " + 1"'') (lua ''hl.dsp.focus({ workspace = 1 })'') ]; }
        { _args = [ (lua ''mod .. " + 2"'') (lua ''hl.dsp.focus({ workspace = 2 })'') ]; }
        { _args = [ (lua ''mod .. " + 3"'') (lua ''hl.dsp.focus({ workspace = 3 })'') ]; }
        { _args = [ (lua ''mod .. " + 4"'') (lua ''hl.dsp.focus({ workspace = 4 })'') ]; }
        { _args = [ (lua ''mod .. " + 5"'') (lua ''hl.dsp.focus({ workspace = 5 })'') ]; }
        { _args = [ (lua ''mod .. " + 6"'') (lua ''hl.dsp.focus({ workspace = 6 })'') ]; }
        { _args = [ (lua ''mod .. " + 7"'') (lua ''hl.dsp.focus({ workspace = 7 })'') ]; }
        { _args = [ (lua ''mod .. " + 8"'') (lua ''hl.dsp.focus({ workspace = 8 })'') ]; }
        { _args = [ (lua ''mod .. " + 9"'') (lua ''hl.dsp.focus({ workspace = 9 })'') ]; }
        { _args = [ (lua ''mod .. " + 0"'') (lua ''hl.dsp.focus({ workspace = 10 })'') ]; }

        # Move active window to workspace
        { _args = [ (lua ''mod .. " + SHIFT + 1"'') (lua ''hl.dsp.window.move({ workspace = 1, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 2"'') (lua ''hl.dsp.window.move({ workspace = 2, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 3"'') (lua ''hl.dsp.window.move({ workspace = 3, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 4"'') (lua ''hl.dsp.window.move({ workspace = 4, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 5"'') (lua ''hl.dsp.window.move({ workspace = 5, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 6"'') (lua ''hl.dsp.window.move({ workspace = 6, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 7"'') (lua ''hl.dsp.window.move({ workspace = 7, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 8"'') (lua ''hl.dsp.window.move({ workspace = 8, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 9"'') (lua ''hl.dsp.window.move({ workspace = 9, follow = true })'') ]; }
        { _args = [ (lua ''mod .. " + SHIFT + 0"'') (lua ''hl.dsp.window.move({ workspace = 10, follow = true })'') ]; }

        # Scroll through workspaces
        { _args = [ (lua ''mod .. " + bracketleft"'') (lua ''hl.dsp.focus({ workspace = "e-1" })'') ]; }
        { _args = [ (lua ''mod .. " + bracketright"'') (lua ''hl.dsp.focus({ workspace = "e+1" })'') ]; }

        # Resize windows with keyboard
        { _args = [ (lua ''mod .. " + ALT + h"'') (lua ''hl.dsp.window.resize({ x = -20, y = 0, relative = true })'') ]; }
        { _args = [ (lua ''mod .. " + ALT + j"'') (lua ''hl.dsp.window.resize({ x = 0, y = 20, relative = true })'') ]; }
        { _args = [ (lua ''mod .. " + ALT + k"'') (lua ''hl.dsp.window.resize({ x = 0, y = -20, relative = true })'') ]; }
        { _args = [ (lua ''mod .. " + ALT + l"'') (lua ''hl.dsp.window.resize({ x = 20, y = 0, relative = true })'') ]; }

        # Move floating windows with arrow keys
        { _args = [ (lua ''mod .. " + Left"'') (lua ''hl.dsp.window.move({ x = -20, y = 0, relative = true })'') ]; }
        { _args = [ (lua ''mod .. " + Down"'') (lua ''hl.dsp.window.move({ x = 0, y = 20, relative = true })'') ]; }
        { _args = [ (lua ''mod .. " + Up"'') (lua ''hl.dsp.window.move({ x = 0, y = -20, relative = true })'') ]; }
        { _args = [ (lua ''mod .. " + Right"'') (lua ''hl.dsp.window.move({ x = 20, y = 0, relative = true })'') ]; }

        # Volume keys
        { _args = [ "XF86AudioLowerVolume" (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'') ]; }
        { _args = [ "XF86AudioRaiseVolume" (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'') ]; }
        { _args = [ "XF86AudioMute" (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'') ]; }
        { _args = [ "XF86AudioMicMute" (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'') ]; }

        # Backlight controls
        { _args = [ "XF86MonBrightnessUp" (lua ''hl.dsp.exec_cmd("brightnessctl set +10%")'') ]; }
        { _args = [ "XF86MonBrightnessDown" (lua ''hl.dsp.exec_cmd("brightnessctl set 10%-")'') ]; }

        # Keyboard layout switching
        { _args = [ "ALT + d" (lua ''hl.dsp.exec_cmd("hyprctl switchxkblayout all 1")'') ]; }
        { _args = [ "ALT + u" (lua ''hl.dsp.exec_cmd("hyprctl switchxkblayout all 0")'') ]; }
        { _args = [ (lua ''mod .. " + ALT + space"'') (lua ''hl.dsp.exec_cmd("hyprctl switchxkblayout all next")'') ]; }
        # Move/resize windows with mouse dragging (mouse binds)
        { _args = [ (lua ''mod .. " + mouse:272"'') (lua ''hl.dsp.window.drag()'') { mouse = true; } ]; }
        { _args = [ (lua ''mod .. " + mouse:273"'') (lua ''hl.dsp.window.resize()'') { mouse = true; } ]; }
      ];
    };

    # Opaque border colors (kept last, matching the previous hyprlang order
    # where this block overrode the rgba values in settings above).
    extraConfig = ''
      hl.config({
        general = {
          col = {
            active_border = "rgb(6cbfbf)",
            inactive_border = "rgb(b3b9b8)",
          },
        },
      })
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
