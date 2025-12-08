# modules/system/flatpak.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable Flatpak service
  services.flatpak.enable = true;

  # Configure XDG portals for Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-xapp
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # Add Flathub repository automatically
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Install some commonly used Flatpaks at system level (optional)
  systemd.services.install-flatpak-apps = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "flatpak-repo.service" ];
    after = [ "flatpak-repo.service" ];
    path = [ pkgs.flatpak ];
    script = ''
      # Install some useful applications
      # flatpak install -y flathub org.mozilla.firefox
      # flatpak install -y flathub com.spotify.Client
      # flatpak install -y flathub org.signal.Signal
      # flatpak install -y flathub com.discordapp.Discord

      # Uncomment the apps you want to install automatically
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Flatpak management tools
  environment.systemPackages = with pkgs; [
    flatpak
    # Flatpak GUI managers for XFCE (uncomment if you want a GUI)
    # warehouse      # Modern Flatpak manager
    # gnome-software # Works without full GNOME (if you want it)
  ];

  # Allow Flatpaks to access fonts and themes
  fonts.fontDir.enable = true;

  # Ensure proper permissions for Flatpak
  security.polkit.enable = true;
}
