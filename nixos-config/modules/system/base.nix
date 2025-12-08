# modules/system/base.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Boot and filesystem
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
    "python3.13-ecdsa-0.19.1"
  ];
  # Nix configuration
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  #security config
  security.sudo = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ]; # No password will be required
          }
        ];
      }
    ];
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

  programs.localsend = {
    enable = true;
    openFirewall = true; # This automatically opens port 53317 TCP/UDP
  };

  # System configuration
  time.timeZone = "America/Denver"; # Adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Override noto-fonts-color-emoji with empty package to avoid build failure
  nixpkgs.overlays = [
    (final: prev: {
      noto-fonts-color-emoji = prev.runCommand "noto-fonts-color-emoji-dummy" {} "mkdir -p $out";
    })
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System services
  services.openssh.enable = true;

  # This value determines the NixOS release
  system.stateVersion = "25.05"; # Don't change unless you know what you're doing!
}
