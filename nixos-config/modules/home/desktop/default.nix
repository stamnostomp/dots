# modules/home/desktop/default.nix
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

    # Desktop packages
    home.packages = with pkgs; [
      # Desktop utilities
      libnotify
      # File managers
      pcmanfm
      thunar
      # Screenshot tools
      grim
      slurp
      grimblast
      # Clipboard utilities
      wl-clipboard
      # System tools
      pavucontrol
    ];

    services.dunst.enable = lib.mkDefault true;

    # Application launcher script for Hyprland
    home.file.".local/bin/app-launcher" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        wofi --show drun
      '';
    };
  };
}
