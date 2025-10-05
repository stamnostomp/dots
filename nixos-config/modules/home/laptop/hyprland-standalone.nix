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

  # Cursor theme
  cursorTheme = {
    name = "Bibata-Modern-Classic";
    size = 20;
  };
in
{
  # Enable Hyprland (laptop-optimized version)
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    
    settings = {
      # Laptop monitor configuration
      monitor = [
        "eDP-1,1920x1080@60,0x0,1"  # Internal laptop display
        ",preferred,auto,1"          # External displays (auto-detect)
      ];

      # Environment variables - cursor settings
      env = [
        "XCURSOR_SIZE,${toString cursorTheme.size}"
        "XCURSOR_THEME,${cursorTheme.name}"
        "WLR_NO_HARDWARE_CURSORS,1" # May be needed for some laptop GPUs
        "GTK_THEME,Everblush"
        "GTK2_RC_FILES,${config.xdg.configHome}/gtk-2.0/gtkrc:${config.home.homeDirectory}/.gtkrc-2.0"
        "XDG_DATA_DIRS,${config.home.profileDirectory}/share:$XDG_DATA_DIRS"
        "QT_QPA_PLATFORMTHEME,gtk2"
      ];

      # Startup applications
      exec-once = [
        "hyprcursor"
        "hyprctl setcursor ${cursorTheme.name} ${toString cursorTheme.size}"
        "waybar"
        "dunst"
        "hyprpaper"
        "nm-applet --indicator"
        "blueman-applet"
        "hypridle"  # Power management
      ];

      # Input configuration (laptop-specific)
      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 1;
        sensitivity = 0.0;
        
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          middle_button_emulation = true;
          scroll_factor = 0.8;
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
          tap-to-click = true;
          middle_button_emulation = true;
          scroll_factor = 0.8;
        }
      ];

      # Battery-optimized appearance settings
      general = {
        gaps_in = 3;         # Smaller gaps to save screen space
        gaps_out = 5;
        border_size = 2;     # Thinner borders
        "col.active_border" = "rgba(6cbfbfee)";
        "col.inactive_border" = "rgba(b3b9b8aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      # Battery-optimized decoration settings
      decoration = {
        rounding = 0;        # No rounding to save GPU cycles
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        
        blur = {
          enabled = false;   # Disable blur to save battery
        };
        
        ###drop_shadow = false; # Disable shadows to save battery
      };

      # Battery-optimized animation settings
      animations = {
        enabled = true;
           };

      # Layout settings optimized for laptop screens
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = true;
        smart_resizing = true;
      };

      # Gestures for touchpad
      gestures = {
       # workspace_swipe = true;
        #workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_create_new = true;
      };

      # Laptop-specific window rules
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(blueman-manager)$"
        "size 800 600,class:^(pavucontrol)$"
      ];

      # Better battery life settings
      misc = {
        vfr = true;          # Variable refresh rate
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        disable_autoreload = true;  # Disable config auto-reload to save resources
        mouse_move_enables_dpms = true;  # Wake screens on mouse movement
        key_press_enables_dpms = true;   # Wake screens on key press
      };

      # Keybindings
      "$mod" = "SUPER";

      bind = [
        # Terminal
        "$mod, Return, exec, alacritty"

        # Program launcher
        "$mod, space, exec, wofi --show drun"
        "$mod ALT, t, exec, wofi --show window"
        "$mod, r, exec, wofi --show run"

        # Emacs
        "$mod, e, exec, ${config.home.homeDirectory}/.local/bin/emacs-wrapper"

        # Web browser
        "$mod, w, exec, firefox"

        # File Manager
        "$mod, m, exec, pcmanfm"

        # Audio mixer
        "$mod, p, exec, alacritty -e pulsemixer"

        # Battery status
        "$mod SHIFT, b, exec, ~/.local/bin/battery-status.sh"

        # Bluetooth manager
        "$mod, b, exec, alacritty -e bluetui"

        # Dock detection
        "$mod, d, exec, ~/.local/bin/dock-handler.sh"

        # Emacs everywhere
        "$mod SHIFT, semicolon, exec, emacsclient -c -e '(emacs-everywhere)'"

        # Close window
        "$mod, q, killactive"

        # Quit/restart Hyprland
        "$mod ALT, q, exit"
        "$mod ALT, r, exec, hyprctl reload"

        # Screenshots
        "$mod ALT, s, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast save area"
        ", Print, exec, grimblast copy area"

        # Fullscreen
        "$mod, f, fullscreen"

        # Window states
        "$mod, t, pseudo"
        "$mod SHIFT, t, togglesplit"
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

        # Volume keys with notifications
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ~/.local/bin/volume-notify.sh"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ~/.local/bin/volume-notify.sh"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ~/.local/bin/volume-notify.sh"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ~/.local/bin/mic-notify.sh"

        # Brightness controls with notifications
        ", XF86MonBrightnessUp, exec, brightnessctl set +5% && ~/.local/bin/brightness-notify.sh"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%- && ~/.local/bin/brightness-notify.sh"

        # Function keys (ThinkPad specific)
        ", XF86Display, exec, wdisplays"
        ", XF86WLAN, exec, ~/.local/bin/toggle-wireless.sh"
        ", XF86NotificationCenter, exec, dunstctl history-pop"
        ", XF86WebCam, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
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
