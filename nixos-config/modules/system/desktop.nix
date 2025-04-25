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
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };
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
  ];

  # Fish shell
  programs.fish.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Optional: if you want Steam Remote Play
    dedicatedServer.openFirewall = true; # Optional: for hosting game servers
  };

}
