# modules/home/desktop/hyprland.nix
{ config, lib, pkgs, inputs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;

  # Cursor theme
  cursorTheme = {
    name = "macOS-BigSur";
    size = 20;
  };
in
{
  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    # Use settings directly rather than extraConfig
    settings = {
      # Monitor configuration with the fixed positioning
      monitor = [
        "DP-1,3440x1440@144,0x1080,1"
        "HDMI-A-1,1920x1080@75,760x0,1"
      ];

      # Environment variables - cursor settings
      env = [
        "XCURSOR_SIZE,${toString cursorTheme.size}"
        "XCURSOR_THEME,${cursorTheme.name}"
        "WLR_NO_HARDWARE_CURSORS,1" # Needed for NVIDIA
        "GTK_THEME,Everblush" # Set GTK theme
      ];

      # Startup applications
      exec-once = [
        "hyprcursor"
        "waybar"
        "dunst"
        "hyprpaper"
        "nm-applet --indicator"
        "blueman-applet"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
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
        pseudotile = true;
        preserve_split = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
      };

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
        "$mod, e, exec, emacs"

        # Web browser
        "$mod, b, exec, firefox"

        # Waybar reload
        "$mod SHIFT, w, exec, killall waybar && waybar &"

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
        "ALT, d, exec, hyprctl keyword input:kb_layout dvorak"
        "ALT, u, exec, hyprctl keyword input:kb_layout us"
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
  };

  # Generate Everblush wallpaper
  home.activation.generateWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.config/hypr
    ${pkgs.imagemagick}/bin/convert -size 1920x1080 "xc:${colors.background}" ~/.config/hypr/wallpaper.png
  '';

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

    # XDG portal
    xdg-desktop-portal-hyprland
  ];
}
# Create Waybar module
cat > modules/home/desktop/waybar.nix << 'EOF'
# modules/home/desktop/waybar.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Waybar configuration
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  # Waybar configuration files
  xdg.configFile = {
    # Waybar config file
    "waybar/config".text = ''
      {
          "layer": "top",
          "position": "top",
          "height": 24,
          "spacing": 0,
          "margin-top": 0,
          "margin-bottom": 0,

          "modules-left": ["custom/space", "custom/left", "hyprland/workspaces", "custom/right"],
          "modules-center": ["custom/left", "hyprland/window", "custom/right"],
          "modules-right": [
              "custom/left", "cpu", "custom/right", "custom/space",
              "custom/left", "memory", "custom/right", "custom/space",
              "custom/left", "disk", "custom/right", "custom/space",
              "custom/left", "pulseaudio", "custom/right", "custom/space",
              "custom/left", "clock", "custom/right", "custom/space",
              "tray"
          ],

          "hyprland/workspaces": {
              "format": "{icon}",
              "on-click": "activate",
              "all-outputs": false,
              "format-icons": {
                  "1": "1",
                  "2": "2",
                  "3": "3",
                  "4": "4",
                  "5": "5",
                  "6": "6",
                  "7": "7",
                  "8": "8",
                  "9": "9",
                  "10": "10",
                  "default": "○"
              },
              "persistent-workspaces": {
                  "1": [],
                  "2": [],
                  "3": [],
                  "4": [],
                  "5": [],
                  "6": [],
                  "7": [],
                  "8": [],
                  "9": [],
                  "10": []
              }
          },

          "hyprland/window": {
              "format": "{}",
              "max-length": 50,
              "separate-outputs": true
          },

          "cpu": {
              "interval": 2,
              "format": "󰘚 {usage}%",
              "max-length": 10
          },

          "memory": {
              "interval": 5,
              "format": "󰍛 {percentage}%",
              "max-length": 10
          },

          "disk": {
              "interval": 30,
              "format": "󰋊 {percentage_used}%",
              "path": "/"
          },

          "pulseaudio": {
              "format": "{icon} {volume}%",
              "format-muted": "󰝟 Muted",
              "format-icons": {
                  "default": ["󰕿", "󰖀", "󰕾"],
                  "headphone": "󰋋"
              },
              "on-click": "pavucontrol"
          },

          "clock": {
              "interval": 1,
              "format": "󰥔 {:%H:%M:%S}",
              "format-alt": "󰃭 {:%Y-%m-%d}"
          },

          "tray": {
              "icon-size": 18,
              "spacing": 10
          },

          "custom/left": {
              "format": ""
          },

          "custom/right": {
              "format": ""
          },

          "custom/space": {
              "format": " "
          }
      }
    '';

    # Waybar CSS
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
          color: #83a598;
      }

      #memory {
          color: #d3869b;
      }

      #disk {
          color: #8ec07c;
      }

      #pulseaudio {
          color: #fabd3f;
      }

      #clock {
          color: #b8bb26;
      }

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

      /* Module styling */
      #cpu, #memory, #disk, #pulseaudio, #clock {
          padding: 0 10px;
          background-color: ${colors.waybarbg};
      }

      #workspaces {
          background-color: ${colors.waybarbg};
          padding: 0 5px;
      }

      #window {
          background-color: ${colors.waybarbg};
      }
    '';
  };

  # Add required packages for Waybar
  home.packages = with pkgs; [
    waybar
  ];
}
