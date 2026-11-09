# modules/system/desktop.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Central Everblush palette (single source of truth for TTY/ly theming)
  everblush = (import ../theme-colors.nix).colors;
  noHash = lib.removePrefix "#";
in
{
  # Display manager: ly (TUI greeter) themed with the Everblush TTY palette
  # (console.colors below). Truecolor 0xSSRRGGBB values.
  services.displayManager.ly = {
    enable = true;
    settings = {
      bg = "0x00${noHash everblush.background}"; # Everblush background
      fg = "0x00${noHash everblush.foreground}"; # Everblush foreground
      border_fg = "0x00${noHash everblush.cyan}"; # Everblush cyan
      error_fg = "0x01${noHash everblush.red}"; # Everblush red, bold
    };
  };

  # Everblush Linux console (TTY) palette: black red green yellow blue
  # magenta cyan white, then the bright variants. Applies to all VTs, so
  # ly and every other TTY app render in Everblush.
  console.colors = map noHash [
    everblush.black
    everblush.red
    everblush.green
    everblush.yellow
    everblush.blue
    everblush.magenta
    everblush.cyan
    everblush.white
    everblush.brightBlack
    everblush.brightRed
    everblush.brightGreen
    everblush.brightYellow
    everblush.brightBlue
    everblush.brightMagenta
    everblush.brightCyan
    everblush.brightWhite
  ];

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
  security.pam.services.ly.enableGnomeKeyring = true;

  # KDE Connect moved to modules/system/kdeconnect.nix (with hyprland-remote-portal
  # for Wayland remote input). Don't re-enable here to keep a single source.
}
