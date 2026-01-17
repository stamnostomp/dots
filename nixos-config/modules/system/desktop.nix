# modules/system/desktop.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable X11 and display manager
  # GDM supports both Wayland (for Hyprland) and X11 (for XFCE)
  services.xserver.enable = true;
  services.displayManager = {
    gdm = {
      enable = true;
      wayland = true; # Keep Wayland support for Hyprland
      autoSuspend = false;
    };
  };

  # Enable XFCE desktop environment (X11 backup)
  services.xserver.desktopManager.xfce.enable = true;
  # Enable sound with Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable ratbagd for gaming mouse configuration
  services.ratbagd.enable = true;

  # Desktop packages
  environment.systemPackages = with pkgs; [
    # Desktop utilities
    firefox-bin
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-xapp

    # XFCE additional utilities
    xfce.xfce4-settings
    xfce.xfce4-screenshooter
    xfce.xfce4-power-manager
    xfce.xfce4-taskmanager

    # Additional utilities that work well with both DEs
    dconf-editor

    # Gaming mouse configuration
    piper
  ];

  # Fish shell
  programs.fish.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable GNOME Keyring (works with XFCE too)
  services.gnome.gnome-keyring.enable = true;

  # Enable PAM integration for GNOME Keyring
  # This allows apps to access the keyring properly
  security.pam.services.gdm-password.enableGnomeKeyring = true;
}
