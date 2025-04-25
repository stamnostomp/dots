# hosts/desktop/default.nix
{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}:

{
  imports = [
    # Import system modules
    ../../modules/system
  ];

  # Basic system settings
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "America/Denver"; # Adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound with Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable X11 and display manager
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # User account
  users.users.stamno = {
    isNormalUser = true;
    description = "stamno";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Base utilities
    wget
    curl
    git
    vim
    nano
    htop

    # Desktop utilities
    firefox-bin
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland

    # Hardware tools
    pciutils
    usbutils

    # Development
    gcc
    gnumake
  ];

  # Fish shell
  programs.fish.enable = true;

  # Enable nix flakes
  nix = {

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "stamno"
      ];
    };
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release with which your system is compatible
  system.stateVersion = "25.05"; # Don't change unless you know what you're doing!
}
