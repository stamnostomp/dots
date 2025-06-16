# modules/system/torrenting.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Transmission BitTorrent client setup
  environment.systemPackages = with pkgs; [
    transmission-gtk # Full Transmission client with GUI
    transmission # Command line tools and daemon
  ];

  # Enable Transmission daemon service
  services.transmission = {
    enable = true;
    settings = {
      # Download directory
      download-dir = "/home/stamno/Downloads/torrents";
      # Allow remote access (for transmission.el)
      rpc-enabled = true;
      rpc-port = 9091;
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist-enabled = false;
      rpc-authentication-required = false;
      # Optional: Set username/password for RPC
      # rpc-username = "stamno";
      # rpc-password = "your-password";
    };
    # User to run transmission as
    user = "stamno";
    group = "users";
  };

  # Create downloads directory
  systemd.tmpfiles.rules = [
    "d /home/stamno/Downloads/torrents 0755 stamno users -"
  ];

  # Optional: Open firewall ports for transmission
  # networking.firewall.allowedTCPPorts = [ 9091 ];
}
