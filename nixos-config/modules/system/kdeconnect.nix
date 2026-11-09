# modules/system/kdeconnect.nix
{ inputs, ... }:

{
  imports = [
    inputs.hyprland-remote-portal.nixosModules.default
  ];

  # KDE Connect daemon + firewall ports 1714-1764 TCP/UDP
  programs.kdeconnect.enable = true;

  # Minimal RemoteDesktop portal backend for Hyprland.
  # xdg-desktop-portal-hyprland does not implement
  # org.freedesktop.portal.RemoteDesktop, so phone-as-mouse fails with
  # "RemoteDesktop portal not authenticated" without this.
  services.hyprland-remote-portal = {
    enable = true;
    trustedApps = [
      "org.kde.kdeconnect"
      "kdeconnect"
    ];
  };
}
