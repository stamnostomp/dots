# modules/system/desktop.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable display manager (greetd + tuigreet works with Hyprland; GDM 50 requires GNOME Shell)
  # Launch via UWSM (programs.hyprland.withUWSM) instead of bare Hyprland so the
  # session gets XDG/Wayland env, the D-Bus activation environment, and
  # graphical-session.target (xdg-desktop-portal) set up correctly.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };
  };

  # Enable sound with Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
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

  # Portals: programs.hyprland already registers xdg-desktop-portal-hyprland,
  # but that backend doesn't implement org.freedesktop.impl.portal.Settings.
  # The GTK portal provides it, so apps (libadwaita, GTK4, Electron, Firefox)
  # can read color-scheme=prefer-dark from dconf and default to dark mode.
  # (Portal packages in environment.systemPackages alone do NOT register them.)
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Desktop packages
  environment.systemPackages = with pkgs; [
    pipewire.jack
    # Desktop utilities
    firefox-bin
    xdg-utils

    # Additional utilities
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

  # Enable GNOME Keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable PAM integration for GNOME Keyring
  security.pam.services.greetd.enableGnomeKeyring = true;
}
