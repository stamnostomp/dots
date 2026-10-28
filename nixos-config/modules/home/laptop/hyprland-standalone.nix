# modules/home/laptop/hyprland-standalone.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Import colors from the theme module
  colorsDef = import ../../../modules/theme-colors.nix;
  colors = colorsDef.colors;

  # Cursor theme from the central theme module
  cursorTheme = colorsDef.cursor;

  lua = lib.generators.mkLuaInline;
in
{
  # Enable Hyprland (laptop-optimized version)
  wayland.windowManager.hyprland = {
    enable = true;
    # Lua config (hyprlang is deprecated since Hyprland 0.55).
    # Generates $XDG_CONFIG_HOME/hypr/hyprland.lua.
    configType = "lua";
    systemd.enable = true;
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

      # Laptop monitor configuration
      monitor = [
        {
          output = "eDP-1";
          mode = "1920x1080@60";
          position = "0x0";
          scale = 1;
        } # Internal laptop display
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
        { _args = [ "WLR_NO_HARDWARE_CURSORS" "1" ]; } # May be needed for some laptop GPUs
        { _args = [ "GTK_THEME" "Everblush" ]; }
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
                hl.exec_cmd("hypridle")
              end
            '')
          ];
        }
      ];

      # Plain config categories (hl.config({...})).
      config = {
        # Input configuration (laptop-specific)
        input = {
          kb_layout = "us,us";
          kb_variant = ",dvorak";
          kb_model = "";
          kb_options = "";
          kb_rules = "";
          follow_mouse = 1;
          sensitivity = 0.0;

          touchpad = {
            natural_scroll = true;
            tap_to_click = true;
            middle_button_emulation = true;
            scroll_factor = 0.8;
          };
        };

        # Battery-optimized appearance settings
        general = {
          gaps_in = 3; # Smaller gaps to save screen space
          gaps_out = 5;
          border_size = 2; # Thinner borders
          col = {
            active_border = "rgba(6cbfbfee)";
            inactive_border = "rgba(b3b9b8aa)";
          };
          layout = "dwindle";
          resize_on_border = true;
        };

        # Battery-optimized decoration settings
        decoration = {
          rounding = 0; # No rounding to save GPU cycles
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          blur = {
            enabled = false; # Disable blur to save battery
          };

          ###drop_shadow = false; # Disable shadows to save battery
        };

        # Battery-optimized animation settings
        animations = {
          enabled = true;
        };

        # Layout settings optimized for laptop screens
        dwindle = {
          preserve_split = true;
          smart_split = true;
          smart_resizing = true;
        };

        # Better battery life settings
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
          disable_autoreload = true; # Disable config auto-reload to save resources
          mouse_move_enables_dpms = true; # Wake screens on mouse movement
          key_press_enables_dpms = true; # Wake screens on key press
        };
      };

      # Device-specific settings
      device = [
        {
          name = "tpps/2-ibm-trackpoint";
          sensitivity = 0.5;
          accel_profile = "flat";
        }
        {
          name = "synaptics-tm2964-001";
          natural_scroll = true;
          tap_to_click = true;
          middle_button_emulation = true;
          scroll_factor = 0.8;
        }
      ];

      # Gestures
      # Laptop-specific window rules
      window_rule = [
        {
          match = {
            class = "^(pavucontrol)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(nm-connection-editor)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(blueman-manager)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pavucontrol)$";
          };
          size = [
            800
            600
          ];
        }
      ];

      # Keybindings
      bind = [
        # Terminal
        { _args = [ (lua ''mod .. " + Return"'') (lua ''hl.dsp.exec_cmd("alacritty")'') ]; }

        # Program launcher
        { _args = [ (lua ''mod .. " + space"'') (lua ''hl.dsp.exec_cmd("wofi --show drun")'') ]; }
        { _args = [ (lua ''mod .. " + ALT + t"'') (lua ''hl.dsp.exec_cmd("wofi --show window")'') ]; }
        { _args = [ (lua ''mod .. " + r"'') (lua ''hl.dsp.exec_cmd("wofi --show run")'') ]; }

        # Emacs
        { _args = [ (lua ''mod .. " + e"'') (lua ''hl.dsp.exec_cmd("${config.home.homeDirectory}/.local/bin/emacs-wrapper")'') ]; }

        # Web browser
        { _args = [ (lua ''mod .. " + w"'') (lua ''hl.dsp.exec_cmd("firefox")'') ]; }

        # File Manager
        { _args = [ (lua ''mod .. " + m"'') (lua ''hl.dsp.exec_cmd("pcmanfm")'') ]; }

        # Audio mixer
        { _args = [ (lua ''mod .. " + p"'') (lua ''hl.dsp.exec_cmd("alacritty -e pulsemixer")'') ]; }

        # Battery status
        { _args = [ (lua ''mod .. " + SHIFT + b"'') (lua ''hl.dsp.exec_cmd("~/.local/bin/battery-status.sh")'') ]; }

        # Bluetooth manager
        { _args = [ (lua ''mod .. " + b"'') (lua ''hl.dsp.exec_cmd("alacritty -e bluetui")'') ]; }

        # Dock detection
        { _args = [ (lua ''mod .. " + d"'') (lua ''hl.dsp.exec_cmd("~/.local/bin/dock-handler.sh")'') ]; }

        # Emacs everywhere
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

        # Volume keys with notifications
        { _args = [ "XF86AudioLowerVolume" (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ~/.local/bin/volume-notify.sh")'') ]; }
        { _args = [ "XF86AudioRaiseVolume" (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ~/.local/bin/volume-notify.sh")'') ]; }
        { _args = [ "XF86AudioMute" (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ~/.local/bin/volume-notify.sh")'') ]; }
        { _args = [ "XF86AudioMicMute" (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ~/.local/bin/mic-notify.sh")'') ]; }

        # Brightness controls with notifications
        { _args = [ "XF86MonBrightnessUp" (lua ''hl.dsp.exec_cmd("brightnessctl set +5% && ~/.local/bin/brightness-notify.sh")'') ]; }
        { _args = [ "XF86MonBrightnessDown" (lua ''hl.dsp.exec_cmd("brightnessctl set 5%- && ~/.local/bin/brightness-notify.sh")'') ]; }

        # Function keys (ThinkPad specific)
        { _args = [ "XF86Display" (lua ''hl.dsp.exec_cmd("wdisplays")'') ]; }
        { _args = [ "XF86WLAN" (lua ''hl.dsp.exec_cmd("~/.local/bin/toggle-wireless.sh")'') ]; }
        { _args = [ "XF86NotificationCenter" (lua ''hl.dsp.exec_cmd("dunstctl history-pop")'') ]; }
        { _args = [ "XF86WebCam" (lua ''hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]])'') ]; }

        # Keyboard layout switching (target the physical keyboard only;
        # "all" also cycles virtual devices like power-button/video-bus/mouse,
        # which don't always stay in sync and desync the waybar indicator)
        { _args = [ (lua ''mod .. " + ALT + space"'') (lua ''hl.dsp.exec_cmd("hyprctl switchxkblayout at-translated-set-2-keyboard next")'') ]; }
        # Move/resize windows with mouse dragging (mouse binds)
        { _args = [ (lua ''mod .. " + mouse:272"'') (lua ''hl.dsp.window.drag()'') { mouse = true; } ]; }
        { _args = [ (lua ''mod .. " + mouse:273"'') (lua ''hl.dsp.window.resize()'') { mouse = true; } ]; }
      ];
    };
  };

  # Laptop-specific configuration files
  xdg.configFile = {
    # Hyprcursor configuration
    "hyprcursor/hyprcursor.toml".text = ''
      theme = "${cursorTheme.name}"
      size = ${toString cursorTheme.size}
    '';

    # Hyprpaper config with minimal resource usage
    "hypr/hyprpaper.conf".text = ''
      preload = ~/.config/hypr/wallpaper-minimal.png
      wallpaper = eDP-1,~/.config/hypr/wallpaper-minimal.png
      ipc = off
      splash = false
    '';

    # Hypridle configuration for power management
    "hypr/hypridle.conf".text = ''
      general {
        lock_cmd = ${pkgs.swaylock}/bin/swaylock -f -c 000000
        unlock_cmd = pkill -USR1 swaylock
        before_sleep_cmd = ${pkgs.swaylock}/bin/swaylock -f -c 000000
        after_sleep_cmd = ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
      }

      listener {
        timeout = 300          # 5 min
        on-timeout = ${pkgs.swaylock}/bin/swaylock -f -c 000000
      }

      listener {
        timeout = 600          # 10 min
        on-timeout = ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
      }

      listener {
        timeout = 900          # 15 min
        on-timeout = systemctl suspend
      }
    '';
  };

  # Create a minimal wallpaper to save resources
  home.activation.generateMinimalWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/hypr
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 "xc:${colors.background}" ~/.config/hypr/wallpaper-minimal.png
  '';

  # Add required packages for laptop Hyprland
  home.packages = with pkgs; [
    # Cursor packages
    hyprcursor
    apple-cursor

    # Wayland utilities
    hyprpaper
    hypridle
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

    # Display management
    wdisplays

    # Audio utilities
    pulsemixer

    # Power management utilities
    acpi
  ];
}
