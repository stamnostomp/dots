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
      thunar
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
        if [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]]; then
          echo "xfce"
        elif [[ "$XDG_CURRENT_DESKTOP" == *"Hyprland"* ]] || [[ "$WAYLAND_DISPLAY" && "$XDG_SESSION_TYPE" == "wayland" ]]; then
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
          "xfce")
            # Use XFCE's application finder or rofi as fallback
            if command -v xfce4-appfinder &> /dev/null; then
              xfce4-appfinder
            elif command -v rofi &> /dev/null; then
              rofi -show drun
            else
              echo "No application launcher found"
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
