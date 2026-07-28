# modules/system/networking.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      4070
    ];
  };

  # Network packages
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
  ];
}
