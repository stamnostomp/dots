#!/usr/bin/env sh


# Create a Modular NixOS Flake Structure
# This script sets up a complete modular NixOS flake structure with all necessary files

# Exit on any error
set -e

# Set the base directory
BASE_DIR="nixos-config"
HOSTNAME="desktop" # Replace with your hostname if different

# Create base directory structure
echo "Creating directory structure..."
mkdir -p "$BASE_DIR"/{hosts/"$HOSTNAME",home/stamno/theme,modules/{system,home/{desktop,shell,terminal}},pkgs/everblush-gtk}

# Navigate to base directory
cd "$BASE_DIR"

# Create flake.nix in the root directory
echo "Creating main flake.nix..."
cat > flake.nix << 'EOF'
{
  description = "NixOS configuration for stamno";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Desktop environment
    hyprland.url = "github:hyprwm/Hyprland";

    # Package overrides and custom packages
    everblush-gtk = {
      url = "path:./pkgs/everblush-gtk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland, everblush-gtk, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Function to make system configuration with given hostname
      mkSystem = hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit hostname;
        };
        modules = [
          # Include the hardware configuration
          ./hosts/${hostname}/hardware.nix

          # Include the host-specific configuration
          ./hosts/${hostname}

          # Make flake inputs available in NixOS
          {
            _module.args.inputs = inputs;
            _module.args.self = self;
          }

          # Include home-manager as a module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit hostname;
            };
            # Import the user-specific configuration
            home-manager.users.stamno = import ./home/stamno;
          }

          # Include Hyprland as a module
          hyprland.nixosModules.default
          {
            programs.hyprland = {
              enable = true;
              xwayland.enable = true;
            };
          }
        ];
      };
    in {
      # NixOS configurations
      nixosConfigurations = {
        "${hostname}" = mkSystem "${hostname}";
        # Add other hosts as needed
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        "stamno@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            hostname = "${hostname}";
          };
          modules = [
            ./home/stamno
          ];
        };
      };

      # Make packages available for dependent flakes
      packages.${system} = {
        inherit (everblush-gtk.packages.${system}) everblush-gtk;
      };
    };
}
EOF

# Create hardware.nix for the hostname
echo "Creating hardware configuration..."
cat > "hosts/$HOSTNAME/hardware.nix" << 'EOF'
# hosts/desktop/hardware.nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3c594be5-3f75-4660-ae81-db8085e191dd";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DF79-3471";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6d07fae1-c87b-41a8-9bfc-fc5eabb028c4"; }
    ];

  # Enables DHCP on each ethernet and wireless interface
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp56s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp57s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Additional hardware settings for your Hyprland setup
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
EOF

# Create default.nix for the hostname
echo "Creating host configuration..."
cat > "hosts/$HOSTNAME/default.nix" << 'EOF'
# hosts/desktop/default.nix
{ config, pkgs, lib, inputs, hostname, ... }:

{
  imports = [
    # Import system modules
    ../../modules/system
  ];

  # Basic system settings
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "America/New_York";  # Adjust to your timezone
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
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
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
    firefox
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
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "stamno" ];
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
EOF

# Create colors.nix
echo "Creating color scheme file..."
mkdir -p home/stamno/theme
cat > home/stamno/theme/colors.nix << 'EOF'
{
  colors = {
    background = "#141b1e";
    foreground = "#dadada";
    cursor = "#dadada";
    black = "#232a2d";
    red = "#e57474";
    green = "#8ccf7e";
    yellow = "#e5c76b";
    blue = "#67b0e8";
    magenta = "#c47fd5";
    cyan = "#6cbfbf";
    white = "#b3b9b8";
    brightBlack = "#2d3437";
    brightRed = "#ef7e7e";
    brightGreen = "#96d988";
    brightYellow = "#f4d67a";
    brightBlue = "#71baf2";
    brightMagenta = "#ce89df";
    brightCyan = "#67cbe7";
    brightWhite = "#bdc3c2";

    # New light background for waybar
    waybarbg = "#232a2d"; # Using the black color as a lighter background
  };
}
EOF

# Create theme.nix
echo "Creating theme configuration..."
cat > home/stamno/theme.nix << 'EOF'
# home/stamno/theme.nix
{ config, lib, pkgs, inputs, ... }:

let
  # Import colors
  inherit (import ./theme/colors.nix) colors;

  # Cursor theme definition
  cursorTheme = {
    name = "macOS-BigSur";
    size = 20;
  };
in
{
  # Set cursor environment variables consistently
  home.sessionVariables = {
    XCURSOR_PATH = "${config.home.profileDirectory}/share/icons:${pkgs.apple-cursor}/share/icons";
    XCURSOR_THEME = cursorTheme.name;
    XCURSOR_SIZE = toString cursorTheme.size;
  };

  # Set consistent cursor configuration across the system for X11
  home.pointerCursor = {
    name = cursorTheme.name;
    package = pkgs.apple-cursor;
    size = cursorTheme.size;
    gtk.enable = true;
    x11.enable = true;
  };

  # Configure GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Everblush";
      package = inputs.everblush-gtk.packages.${pkgs.system}.default;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = cursorTheme.name;
      package = pkgs.apple-cursor;
      size = cursorTheme.size;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  # Configure Wofi application launcher with theme
  programs.wofi = {
    enable = true;
    settings = {
      width = 500;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
    };
    style = ''
      window {
        background-color: ${colors.background};
        color: ${colors.foreground};
        border: 2px solid ${colors.blue};
        border-radius: 8px;
      }

      #input {
        border: 2px solid ${colors.black};
        background-color: ${colors.brightBlack};
        color: ${colors.foreground};
        border-radius: 4px;
        margin: 4px;
        padding: 8px;
      }

      #outer-box {
        margin: 10px;
      }

      #entry:selected {
        background-color: ${colors.blue};
        color: ${colors.background};
        border-radius: 4px;
      }
    '';
  };

  # Add theme-related packages
  home.packages = with pkgs; [
    # Theme dependencies
    gtk-engine-murrine
    gtk_engines

    # Icon theme
    papirus-icon-theme

    # Cursor theme
    apple-cursor
  ];
}
EOF

# Create programs.nix
echo "Creating programs configuration..."
cat > home/stamno/programs.nix << 'EOF'
# home/stamno/programs.nix
{ config, lib, pkgs, inputs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "stamno";  # Replace with your actual name
    userEmail = "your.email@example.com";  # Replace with your email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";
    };
  };

  # Direnv for per-directory environment variables
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Application packages
  home.packages = with pkgs; [
    # Browsers
    firefox

    # Development tools
    git
    ripgrep
    htop
    btop

    # Text editors
    emacs

    # File managers
    xfce.thunar
    kdePackages.dolphin

    # Messaging and communication
    signal-desktop-source
    vesktop

    # System utilities
    imagemagick
    wl-clipboard
    grim  # Screenshot utility
    slurp  # Area selection for screenshots
    grimblast  # Wrapper for grim and slurp

    # Audio utilities
    pamixer  # CLI audio control
    pavucontrol  # GUI audio control

    # Other utilities
    xdg-utils
    libnotify  # Notification library
  ];

  # Starship prompt (optional)
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      nix_shell = {
        format = "via [☃️ $state( $name)](bold blue) ";
        heuristic = true;
      };
    };
  };
}
EOF

# Create default.nix (home-manager main file)
echo "Creating home-manager main configuration..."
cat > home/stamno/default.nix << 'EOF'
# home/stamno/default.nix
{ config, pkgs, lib, inputs, ... }:

let
  # Import color scheme
  colors = import ./theme/colors.nix;
in
{
  imports = [
    # Import home-manager modules for different components
    ./programs.nix
    ./theme.nix

    # Import reusable home-manager modules
    ../../modules/home/desktop/hyprland.nix
    ../../modules/home/desktop/waybar.nix
    ../../modules/home/desktop/dunst.nix
    ../../modules/home/shell/bash.nix
    ../../modules/home/shell/fish.nix
    ../../modules/home/terminal/alacritty.nix
    ../../modules/home/terminal/kitty.nix
  ];

  # Home Manager basics
  home.username = "stamno";
  home.homeDirectory = "/home/stamno";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Make the Everblush GTK theme available
  home.packages = with pkgs; [
    # Make the Everblush GTK theme available
    inputs.everblush-gtk.packages.${pkgs.system}.default
  ];

  # Set GTK theme in the environment to ensure it works everywhere
  home.sessionVariables = {
    GTK_THEME = "Everblush";
  };
}
EOF

# Create system modules
echo "Creating system modules..."
mkdir -p modules/system

# Base system module
cat > modules/system/base.nix << 'EOF'
# modules/system/base.nix
{ config, lib, pkgs, ... }:

{
  # Boot and filesystem
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix configuration
  nix = {
    package = pkgs.nixFlakes;
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
EOF

# Desktop environment module
cat > modules/system/desktop.nix << 'EOF'
# modules/system/desktop.nix
{ config, lib, pkgs, ... }:

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
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Desktop packages
  environment.systemPackages = with pkgs; [
    # Desktop utilities
    firefox
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];

  # Fish shell
  programs.fish.enable = true;
}
EOF

# Networking module
cat > modules/system/networking.nix << 'EOF'
# modules/system/networking.nix
{ config, lib, pkgs, ... }:

{
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Network packages
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
  ];
}
EOF

# Import all the system modules
cat > modules/system/default.nix << 'EOF'
# modules/system/default.nix
{ ... }:

{
  imports = [
    ./base.nix
    ./desktop.nix
    ./networking.nix
  ];
}
EOF

# Create home-manager modules
echo "Creating home-manager modules..."

# Create Hyprland module
mkdir -p modules/home/desktop
cat > modules/home/desktop/hyprland.nix << 'EOF'
# modules/home/desktop/hyprland.nix
{ config, lib, pkgs, inputs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;

  # Cursor theme
  cursorTheme = {
    name = "macOS-BigSur";
    size = 20;
  };
in
{
  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    # Use settings directly rather than extraConfig
    settings = {
      # Monitor configuration with the fixed positioning
      monitor = [
        "DP-1,3440x1440@144,0x1080,1"
        "HDMI-A-1,1920x1080@75,760x0,1"
      ];

      # Environment variables - cursor settings
      env = [
        "XCURSOR_SIZE,${toString cursorTheme.size}"
        "XCURSOR_THEME,${cursorTheme.name}"
        "WLR_NO_HARDWARE_CURSORS,1" # Needed for NVIDIA
        "GTK_THEME,Everblush" # Set GTK theme
      ];

      # Startup applications
      exec-once = [
        "hyprcursor"
        "waybar"
        "dunst"
        "hyprpaper"
        "nm-applet --indicator"
        "blueman-applet"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 1;
        sensitivity = 0.0;
        touchpad = {
          natural_scroll = false;
        };
      };

      # Appearance
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "rgba(6cbfbfee)";
        "col.inactive_border" = "rgba(b3b9b8aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      # Decoration settings
      decoration = {
        rounding = 0;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
      };

      # Window rules
      windowrule = [
        # Your window rules here
      ];

      # Keybindings
      "$mod" = "SUPER";

      # Keybinds
      bind = [
        # Terminal
        "$mod, Return, exec, alacritty"

        # Program launcher
        "$mod, space, exec, wofi --show drun"
        "$mod ALT, t, exec, wofi --show window"
        "$mod, r, exec, wofi --show run"

        # Power menu
        "$mod SHIFT, p, exec, wlogout"

        # Emacs
        "$mod, e, exec, emacs"

        # Web browser
        "$mod, b, exec, firefox"

        # Waybar reload
        "$mod SHIFT, w, exec, killall waybar && waybar &"

        # Close window
        "$mod, q, killactive"

        # Quit/restart Hyprland
        "$mod ALT, q, exit"
        "$mod ALT, r, exec, hyprctl reload"

        # Screenshots
        "$mod ALT, s, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast save area"
        ", Print, exec, grimblast copy area"

        # Fullscreen
        "$mod, f, fullscreen"

        # Window states
        "$mod, t, pseudo"
        "$mod SHIFT, t, togglesplit"
        "$mod, s, togglefloating"

        # Focus windows
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # Move windows
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scroll through workspaces
        "$mod, bracketleft, workspace, e-1"
        "$mod, bracketright, workspace, e+1"

        # Resize windows with keyboard
        "$mod ALT, h, resizeactive, -20 0"
        "$mod ALT, j, resizeactive, 0 20"
        "$mod ALT, k, resizeactive, 0 -20"
        "$mod ALT, l, resizeactive, 20 0"

        # Move floating windows with arrow keys
        "$mod, Left, moveactive, -20 0"
        "$mod, Down, moveactive, 0 20"
        "$mod, Up, moveactive, 0 -20"
        "$mod, Right, moveactive, 20 0"

        # Volume keys
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        # Backlight controls
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

        # Keyboard layout switching
        "ALT, d, exec, hyprctl keyword input:kb_layout dvorak"
        "ALT, u, exec, hyprctl keyword input:kb_layout us"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Additional settings
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };
    };
  };

  # Set up configuration files for Hyprland
  xdg.configFile = {
    # Hyprcursor configuration
    "hyprcursor/hyprcursor.toml".text = ''
      theme = "${cursorTheme.name}"
      size = ${toString cursorTheme.size}
    '';

    # Hyprpaper config
    "hypr/hyprpaper.conf".text = ''
      preload = ~/.config/hypr/wallpaper.png
      wallpaper = DP-1,~/.config/hypr/wallpaper.png
      wallpaper = HDMI-A-1,~/.config/hypr/wallpaper.png
      splash = false
    '';
  };

  # Generate Everblush wallpaper
  home.activation.generateWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.config/hypr
    ${pkgs.imagemagick}/bin/convert -size 1920x1080 "xc:${colors.background}" ~/.config/hypr/wallpaper.png
  '';

  # Add required packages for Hyprland
  home.packages = with pkgs; [
    # Cursor packages
    hyprcursor
    apple-cursor

    # Wayland utilities
    hyprpaper
    wl-clipboard
    grim
    slurp
    grimblast
    wlr-randr
    wlogout
    swaylock-effects

    # Screen brightness
    brightnessctl

    # System tray applications
    networkmanagerapplet
    blueman

    # XDG portal
    xdg-desktop-portal-hyprland
  ];
}
# Create Waybar module
cat > modules/home/desktop/waybar.nix << 'EOF'
# modules/home/desktop/waybar.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Waybar configuration
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  # Waybar configuration files
  xdg.configFile = {
    # Waybar config file
    "waybar/config".text = ''
      {
          "layer": "top",
          "position": "top",
          "height": 24,
          "spacing": 0,
          "margin-top": 0,
          "margin-bottom": 0,

          "modules-left": ["custom/space", "custom/left", "hyprland/workspaces", "custom/right"],
          "modules-center": ["custom/left", "hyprland/window", "custom/right"],
          "modules-right": [
              "custom/left", "cpu", "custom/right", "custom/space",
              "custom/left", "memory", "custom/right", "custom/space",
              "custom/left", "disk", "custom/right", "custom/space",
              "custom/left", "pulseaudio", "custom/right", "custom/space",
              "custom/left", "clock", "custom/right", "custom/space",
              "tray"
          ],

          "hyprland/workspaces": {
              "format": "{icon}",
              "on-click": "activate",
              "all-outputs": false,
              "format-icons": {
                  "1": "1",
                  "2": "2",
                  "3": "3",
                  "4": "4",
                  "5": "5",
                  "6": "6",
                  "7": "7",
                  "8": "8",
                  "9": "9",
                  "10": "10",
                  "default": "○"
              },
              "persistent-workspaces": {
                  "1": [],
                  "2": [],
                  "3": [],
                  "4": [],
                  "5": [],
                  "6": [],
                  "7": [],
                  "8": [],
                  "9": [],
                  "10": []
              }
          },

          "hyprland/window": {
              "format": "{}",
              "max-length": 50,
              "separate-outputs": true
          },

          "cpu": {
              "interval": 2,
              "format": "󰘚 {usage}%",
              "max-length": 10
          },

          "memory": {
              "interval": 5,
              "format": "󰍛 {percentage}%",
              "max-length": 10
          },

          "disk": {
              "interval": 30,
              "format": "󰋊 {percentage_used}%",
              "path": "/"
          },

          "pulseaudio": {
              "format": "{icon} {volume}%",
              "format-muted": "󰝟 Muted",
              "format-icons": {
                  "default": ["󰕿", "󰖀", "󰕾"],
                  "headphone": "󰋋"
              },
              "on-click": "pavucontrol"
          },

          "clock": {
              "interval": 1,
              "format": "󰥔 {:%H:%M:%S}",
              "format-alt": "󰃭 {:%Y-%m-%d}"
          },

          "tray": {
              "icon-size": 18,
              "spacing": 10
          },

          "custom/left": {
              "format": ""
          },

          "custom/right": {
              "format": ""
          },

          "custom/space": {
              "format": " "
          }
      }
    '';

    # Waybar CSS
    "waybar/style.css".text = ''
      * {
          font-family: "Cozette", "JetBrainsMono Nerd Font", "Siji", "FontAwesome";
          font-size: 13px;
          border: none;
          border-radius: 0;
      }

      window#waybar {
          background-color: ${colors.waybarbg};
          color: #dadada;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #dadada;
      }

      #workspaces button.active {
          background-color: #32302f;
          color: #dadada;
          border-bottom: 2px solid #427b58;
      }

      #workspaces button:hover {
          background: rgba(50, 48, 47, 0.5);
      }

      #window {
          padding: 0 10px;
      }

      #cpu {
          color: #83a598;
      }

      #memory {
          color: #d3869b;
      }

      #disk {
          color: #8ec07c;
      }

      #pulseaudio {
          color: #fabd3f;
      }

      #clock {
          color: #b8bb26;
      }

      #custom-left {
          font-size: 20px;
          color: ${colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      #custom-right {
          font-size: 20px;
          color: ${colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      /* Module styling */
      #cpu, #memory, #disk, #pulseaudio, #clock {
          padding: 0 10px;
          background-color: ${colors.waybarbg};
      }

      #workspaces {
          background-color: ${colors.waybarbg};
          padding: 0 5px;
      }

      #window {
          background-color: ${colors.waybarbg};
      }
    '';
  };

  # Add required packages for Waybar
  home.packages = with pkgs; [
    waybar
  ];
}
EOF

# Create Dunst module
cat > modules/home/desktop/dunst.nix << 'EOF'
# modules/home/desktop/dunst.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Dunst notification daemon
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "10x50";
        origin = "top-right";
        transparency = 10;
        frame_color = colors.blue;
        separator_color = "frame";
        font = "monospace 11";
      };

      urgency_low = {
        background = colors.background;
        foreground = colors.foreground;
        timeout = 5;
      };

      urgency_normal = {
        background = colors.background;
        foreground = colors.foreground;
        timeout = 10;
      };

      urgency_critical = {
        background = colors.background;
        foreground = colors.red;
        frame_color = colors.red;
        timeout = 0;
      };
    };
  };

  # Add required packages for Dunst
  home.packages = with pkgs; [
    libnotify
  ];
}
EOF

# Create Terminal modules
mkdir -p modules/home/terminal

# Alacritty module
cat > modules/home/terminal/alacritty.nix << 'EOF'
# modules/home/terminal/alacritty.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Alacritty terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "none";
        opacity = 0.95;
      };
      font = {
        normal = {
          family = "monospace";
          style = "Regular";
        };
        size = 11.0;
      };
      colors = {
        primary = {
          background = colors.background;
          foreground = colors.foreground;
        };
        cursor = {
          text = colors.background;
          cursor = colors.cursor;
        };
        normal = {
          black = colors.black;
          red = colors.red;
          green = colors.green;
          yellow = colors.yellow;
          blue = colors.blue;
          magenta = colors.magenta;
          cyan = colors.cyan;
          white = colors.white;
        };
        bright = {
          black = colors.brightBlack;
          red = colors.brightRed;
          green = colors.brightGreen;
          yellow = colors.brightYellow;
          blue = colors.brightBlue;
          magenta = colors.brightMagenta;
          cyan = colors.brightCyan;
          white = colors.brightWhite;
        };
      };
    };
  };
}
EOF

# Kitty module
cat > modules/home/terminal/kitty.nix << 'EOF'
# modules/home/terminal/kitty.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "monospace";
      font_size = "11.0";
      window_padding_width = "10";
      background_opacity = "0.95";

      # Everblush Colors
      foreground = colors.foreground;
      background = colors.background;
      cursor = colors.cursor;

      color0 = colors.black;
      color1 = colors.red;
      color2 = colors.green;
      color3 = colors.yellow;
      color4 = colors.blue;
      color5 = colors.magenta;
      color6 = colors.cyan;
      color7 = colors.white;

      color8 = colors.brightBlack;
      color9 = colors.brightRed;
      color10 = colors.brightGreen;
      color11 = colors.brightYellow;
      color12 = colors.brightBlue;
      color13 = colors.brightMagenta;
      color14 = colors.brightCyan;
      color15 = colors.brightWhite;
    };
  };
}
EOF

# Create Shell modules
mkdir -p modules/home/shell

# Bash configuration
cat > modules/home/shell/bash.nix << 'EOF'
# modules/home/shell/bash.nix
{ config, lib, pkgs, ... }:

{
  # Bash configuration
  programs.bash = {
    enable = true;
    initExtra = ''
      # Better nix-shell integration
      if [ -e /etc/profile ]; then
        source /etc/profile
      fi

      # Add nix-shell indicator to prompt
      __prompt_nix_shell() {
        if [ -n "$IN_NIX_SHELL" ]; then
          echo -n " (nix-shell) "
        fi
      }

      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__prompt_nix_shell)\$ '
    '';
  };
}
EOF

# Fish configuration
cat > modules/home/shell/fish.nix << 'EOF'
# modules/home/shell/fish.nix
{ config, lib, pkgs, ... }:

{
  # Fish shell configuration
  programs.fish = {
    enable = true;
    plugins = [
      { name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }
    ];

    interactiveShellInit = ''
      # Set environment variables
      set -gx GTK_THEME "Everblush"

      # Nix shell integration for fish
      function __fish_nix_shell_prompt
        if set -q IN_NIX_SHELL
          echo -n " (nix-shell)"
        end
      end

      # Add the nix-shell status to the prompt
      functions -c fish_prompt _old_fish_prompt
      function fish_prompt
        _old_fish_prompt
        __fish_nix_shell_prompt
      end
    '';
  };
}
EOF

# Copy your everblush-gtk flake to the new folder
echo "Setting up Everblush GTK theme..."
mkdir -p pkgs/everblush-gtk

cat > pkgs/everblush-gtk/flake.nix << 'EOF'
{
  description = "Everblush GTK Theme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          everblush-gtk = pkgs.stdenv.mkDerivation {
            pname = "everblush-gtk";
            version = "1.0.0";

            src = pkgs.fetchFromGitHub {
              owner = "Everblush";
              repo = "gtk";
              rev = "main";
              sha256 = "sha256-bVMwXCNncv47Ksjyq6pc1EU4Ede6PCefd1+I62wM0Lk=";
            };

            nativeBuildInputs = with pkgs; [
              gnumake
              nodePackages.sass
            ];

            propagatedUserEnvPkgs = with pkgs; [
              gtk-engine-murrine
              gtk_engines
            ];

            buildPhase = ''
              make
            '';

            installPhase = ''
              mkdir -p $out/share/themes/Everblush
              cp -r gtk-* $out/share/themes/Everblush/
              cp -r assets $out/share/themes/Everblush/ || true
              cp -r index.theme $out/share/themes/Everblush/ || true
            '';

            meta = with pkgs.lib; {
              description = "Everblush GTK Theme";
              homepage = "https://github.com/Everblush/gtk";
              license = licenses.mit;
              platforms = platforms.all;
              maintainers = [ ];
            };
          };

          default = everblush-gtk;
        };
      }
    );
}
EOF

# Make the script executable
chmod +x setup.sh

# Final instructions
echo ""
echo "---------------------------------------------------------"
echo "Setup completed! Your flake structure is now ready."
echo ""
echo "Next steps:"
echo "1. cd nixos-config"
echo "2. sudo nixos-rebuild switch --flake .#desktop"
echo ""
echo "Note: Make sure to backup your current NixOS configuration"
echo "before switching to the new one."
echo "---------------------------------------------------------"
