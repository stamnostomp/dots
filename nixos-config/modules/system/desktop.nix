# modules/system/desktop.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable X11 and display manager
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
      autoSuspend = false;
    };
    # Enable GNOME desktop environment
    desktopManager.gnome.enable = true;
  };

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

  # Desktop packages
  environment.systemPackages = with pkgs; [
    # Desktop utilities
    firefox-bin
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gnome

    # GNOME-specific packages (optional but recommended)
    gnome-tweaks
    gnome-extension-manager

    # Additional utilities that work well with both DEs
    dconf-editor
  ];

  # Exclude some GNOME applications you might not want
  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-photos
      gnome-tour
      gedit # Use your preferred editor instead
      cheese # webcam tool
      gnome-music
      epiphany # gnome web browser
      geary # email reader
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]
  );

  # Fish shell
  programs.fish.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # GNOME services
  services.gnome = {
    gnome-keyring.enable = true;
    tracker-miners.enable = true;
    tracker.enable = true;
  };
}
