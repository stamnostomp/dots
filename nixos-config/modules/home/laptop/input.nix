# nixos-config/modules/home/laptop/input.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Add specific input settings for Hyprland
  wayland.windowManager.hyprland.settings = {
    # TrackPoint settings
    "device:tpps/2-ibm-trackpoint" = {
      sensitivity = 0.5; # Adjust as needed
      accel_profile = "flat";
    };

    # Touchpad settings
    "device:synaptics-tm2964-001" = {
      natural_scroll = true;
      tap-to-click = true;
      middle_button_emulation = true;
      scroll_factor = 0.8; # Adjust as needed
    };

    # General input settings
    input = {
      kb_layout = "us";
      kb_variant = "";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = true;
        tap-to-click = true;
        scroll_factor = 0.8;
      };
      sensitivity = 0.0;
    };
  };

  # Add tools for input device management
  home.packages = with pkgs; [
    libinput
    xorg.xev # For debugging key inputs
    wev # Wayland event viewer
  ];
}
