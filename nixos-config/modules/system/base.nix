# modules/system/base.nix
{ config, lib, pkgs, ... }:

{
  # Boot and filesystem
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix configuration
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Basic utilities
    wget
    curl
    vim
    nano
    git
    htop

    # System tools
    pciutils
    usbutils
  ];

  # System configuration
  time.timeZone = "America/New_York";  # Adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System services
  services.openssh.enable = true;

  # This value determines the NixOS release
  system.stateVersion = "25.05"; # Don't change unless you know what you're doing!
}
