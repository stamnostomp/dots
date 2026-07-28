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
    # vesktop builds with pnpm 10.29.2; pnpm runs only in the build sandbox.
    "pnpm-10.29.2"
    "electron-40.10.5"
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
      trusted-public-keys = [
        "192.168.1.200-1:T/3Ze/z+ne6hznvf+4gfXgt6SAeFCx7F229956UMTYk="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Remote builder
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "192.168.1.200";
        sshUser = "stamno";
        sshKey = "/home/stamno/.ssh/id_ed25519";
        system = "x86_64-linux";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };

  # Trust the remote builder's host key (used by root's ssh client for distributed builds)
  programs.ssh.knownHosts."192.168.1.200" = {
    hostNames = [ "192.168.1.200" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjDVf/mTMhHY1H3dgrisQa/sVNlBPT6yy+Kd0hO3Lp5";
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
      noto-fonts-color-emoji = prev.runCommand "noto-fonts-color-emoji-dummy" { } "mkdir -p $out";
    })
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Pin dbus implementation to avoid boot issues when switching to broker.
  # mkForce overrides UWSM's module, which otherwise sets this to "broker".
  services.dbus.implementation = lib.mkForce "dbus";

  # System services
  services.openssh.enable = true;

  services.udev.extraRules = ''
    # ESP32-S3 normal mode
    ATTRS{idVendor}=="303a", ATTRS{idProduct}=="81b4", MODE="0666", GROUP="users"
    # ESP32-S3 bootloader/flash mode (Espressif generic)
    ATTRS{idVendor}=="303a", ATTRS{idProduct}=="0002", MODE="0666", GROUP="users"
  '';

  # This value determines the NixOS release
  system.stateVersion = "25.05"; # Don't change unless you know what you're doing!
}
