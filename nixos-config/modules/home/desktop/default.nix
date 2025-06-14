# modules/home/desktop/default.nix (fixed)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Import all modules at the top level - imports can't be conditional like this
  imports = [
    ./dunst.nix
    ./audio.nix
    ./hyprland.nix
    ./waybar.nix
  ];

  # Create an option to enable/disable Hyprland-specific configs
  options = {
    custom.desktop.enableHyprlandConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Hyprland-specific desktop configuration";
    };
  };

  config = {
    # Conditionally enable/disable Hyprland services based on the option
    wayland.windowManager.hyprland.enable = lib.mkDefault config.custom.desktop.enableHyprlandConfig;
    programs.waybar.enable = lib.mkDefault config.custom.desktop.enableHyprlandConfig;

    # Packages that are useful for both desktop environments
    home.packages = with pkgs; [
      # Common desktop utilities
      libnotify
      # File managers (useful as alternatives to GNOME Files)
      pcmanfm
      xfce.thunar
      # Screenshot tools (work in both Wayland and X11)
      grim
      slurp
      grimblast
      # Clipboard utilities
      wl-clipboard
      xclip
      # Common system tools
      pavucontrol
    ];

    # Services that work well with both desktop environments
    services.dunst.enable = lib.mkDefault true;

    # Create a desktop environment detection script
    home.file.".local/bin/detect-desktop" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
          echo "gnome"
        elif [[ "$XDG_CURRENT_DESKTOP" == *"Hyprland"* ]] || [[ "$WAYLAND_DISPLAY" && "$XDG_SESSION_TYPE" == "wayland" && -z "$GNOME_DESKTOP_SESSION_ID" ]]; then
          echo "hyprland"
        else
          echo "unknown"
        fi
      '';
    };

    # Create conditional application launcher script
    home.file.".local/bin/app-launcher" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        DESKTOP=$($HOME/.local/bin/detect-desktop)
        case $DESKTOP in
          "gnome")
            # Use GNOME's overview (Super key) or rofi as fallback
            if command -v rofi &> /dev/null; then
              rofi -show drun
            else
              # Trigger GNOME overview
              gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "Main.overview.toggle();"
            fi
            ;;
          "hyprland")
            # Use wofi for Hyprland
            wofi --show drun
            ;;
          *)
            # Fallback to rofi or dmenu
            if command -v rofi &> /dev/null; then
              rofi -show drun
            elif command -v dmenu &> /dev/null; then
              dmenu_run
            else
              echo "No application launcher found"
            fi
            ;;
        esac
      '';
    };
  };
}
