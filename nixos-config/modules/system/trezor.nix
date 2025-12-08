# modules/system/trezor.nix (Final version)
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable Trezor daemon - but we'll configure it to not interfere
  services.trezord.enable = true;

  # Add comprehensive udev rules for Trezor devices
  services.udev.packages = with pkgs; [
    trezor-udev-rules
  ];

  # CRITICAL: Override with working udev rules
  services.udev.extraRules = ''
    # Trezor One
    SUBSYSTEM=="usb", ATTR{idVendor}=="534c", ATTR{idProduct}=="0001", MODE="0666", GROUP="trezor", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="534c", ATTRS{idProduct}=="0001", MODE="0666", GROUP="trezor", TAG+="uaccess"

    # Trezor Model T
    SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="53c1", MODE="0666", GROUP="trezor", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="53c1", MODE="0666", GROUP="trezor", TAG+="uaccess"

    # Trezor Safe 3
    SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="53c0", MODE="0666", GROUP="trezor", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="53c0", MODE="0666", GROUP="trezor", TAG+="uaccess"

    # Broader permissions for all Trezor devices
    ATTRS{idVendor}=="534c", MODE="0666", GROUP="trezor"
    ATTRS{idVendor}=="1209", ATTR{idProduct}=="53c[01]", MODE="0666", GROUP="trezor"
  '';

  # Create groups
  users.groups.trezor = { };
  users.groups.plugdev = { };

  # Add user to trezor group
  users.users.stamno.extraGroups = [
    "trezor"
    "plugdev"
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    trezor-suite
    # trezorctl # Temporarily disabled due to dependency conflict with click
    usbutils
    libusb1
  ];

  # Enable necessary services
  services.udev.enable = true;
  security.polkit.enable = true;

  # Allow access to USB devices for trezor group
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount") &&
            subject.isInGroup("trezor")) {
            return polkit.Result.YES;
        }
    });
  '';

  # Make sure systemd doesn't interfere with USB permissions
  systemd.services.trezord.serviceConfig = {
    # Allow trezord to access USB devices
    SupplementaryGroups = [
      "trezor"
      "plugdev"
    ];
  };
}
