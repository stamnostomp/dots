{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Package installation
  home.packages = with pkgs; [
    # Core utilities
    eza
    fd
    ripgrep
    fzf
    tree
    git
    curl
    wget
    htop
    btop
    killall
    unzip
    zip
    p7zip
    jq
    yq-go
    xclip
    wl-clipboard
    brightnessctl
    playerctl
    pamixer
    networkmanagerapplet
    blueman
    gnome-keyring
    seahorse
    libsecret

    # File managers
    nautilus
    nemo
    file-roller

    # Media
    mpv
    imv
    pavucontrol
    pulsemixer

    # Productivity
    obsidian
    onlyoffice-desktopeditors
    libreoffice
    zathura
    evince

    # Communication
    vesktop
    #discord (use vesktop instead)
    element-desktop

    # Development
    neovide
    rustup
    nodejs
    bun
    python3
    go
    #zig
    #godot
    #docker
    lazygit
    gh
    act
    just
    direnv
    nix-direnv

    # System monitoring/tools
    mission-center
    gparted
    nvtopPackages.amd
    lm_sensors
    hwinfo

    # Theming
    nwg-look
    #gtk-engine-murrine
    #gtk_engines
    gsettings-desktop-schemas

    # Screenshot tools
    grim
    slurp
    swappy

    # Wayland utilities
    wlogout
    waybar
    rofi
    hyprpicker
    hyprpaper
    hyprlock
    hypridle
    hyprsunset
    hyprpolkitagent

    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

    # Audio
    spotify
    #spotifywm
    librespot

    # Bluetooth utilities
    bluetui

    # Other utilities
    xdg-utils
    libnotify
    mpv

    # Games
    steam
    protonup-ng
    lutris
    inputs.deadlock-mod-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
    #godot

    # CAD
    #freecad-wayland
    # freecad disabled: no binary substitute on nixos-unstable-small rev 7a1ebac
    # (needs local build of ifcopenshell + freecad, hours + big-parallel).
    # Re-enable once `nixos-rebuild dry-build` shows 0 freecad drvs, or use flatpak.
    freecad # temporarily disabled: pulls in pdal-2.9.3, which fails to build
    #kicad is provided by modules/home/cad/kicad.nix (with declarative lib tables)
    #
    # openscad disabled for same reason: heavy CAD stack, re-enable after base system builds
    openscad
    opencode
    # 3D printing - using standard orca-slicer from nixpkgs
    orca-slicer
    prusa-slicer

    # proton
    proton-vpn
    proton-vpn-cli
    proton-pass
    protonmail-desktop

    #minecraft
    prismlauncher

    # Win
    winetricks
  ];

  # KDE Connect "Run commands" for the paired phone (Pixel 9).
  # Lets the phone open the Hyprland app launcher and close the active window.
  # NOTE: keyed by the phone's device ID; a new phone = new directory.
  # If you edit commands in the KDE Connect Settings UI, a rebuild will
  # restore this file (home-manager backup extension is set).
  xdg.configFile."kdeconnect/80ead5bcccef47fa893f0a3e14dd9acf/kdeconnect_runcommand/config".text = ''
    [General]
    commands="@ByteArray({\"d2e5de32_9ffc_4542_9a11_96354b9cf51e\":{\"command\":\"zen-beta\",\"name\":\"zen-browser\"},\"2ffac3fd_8420_4fef_ad8d_e87f1ed8c75e\":{\"command\":\"/home/stamno/.local/bin/app-launcher\",\"name\":\"Open App Menu\"},\"dd11a933_489a_4823_a273_37fdb12bab7d\":{\"command\":\"/run/current-system/sw/bin/hyprctl dispatch killactive\",\"name\":\"Close Window\"}})"
  '';

  # Force Zink for OrcaSlicer via desktop entry override
  xdg.desktopEntries."OrcaSlicer" = {
    name = "OrcaSlicer";
    genericName = "3D Printing Software";
    comment = "G-code generator for 3D printers";
    exec = "env MESA_LOADER_DRIVER_OVERRIDE=zink ${pkgs.orca-slicer}/bin/orca-slicer %F";
    icon = "OrcaSlicer";
    terminal = false;
    type = "Application";
    categories = [
      "Graphics"
      "3DGraphics"
      "Engineering"
    ];
    mimeType = [
      "model/stl"
      "model/3mf"
      "application/vnd.ms-3mfdocument"
      "application/prs.wavefront-obj"
      "application/x-amf"
    ];
  };
}
