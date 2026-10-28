{
  config,
  pkgs,
  lib,
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
