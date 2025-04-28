# home/stamno/programs.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "stamno"; # Replace with your actual name
    userEmail = "stamno@stamno.com"; # Replace with your email
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
    firefox-bin

    # The Everblush Firefox theme - use the input directly
    inputs.firefox-everblush-theme.packages.${system}.default

    # Development tools
    git
    ripgrep
    htop
    btop

    # File managers
    pcmanfm # Lightweight GTK+ file manager
    xfce.thunar
    kdePackages.dolphin

    # Messaging and communication
    signal-desktop
    vesktop

    # System utilities
    imagemagick
    wl-clipboard
    grim # Screenshot utility
    slurp # Area selection for screenshots
    grimblast # Wrapper for grim and slurp

    # Audio utilities
    pulsemixer
    easyeffects

    # Other utilities
    xdg-utils
    libnotify

    # Games
    steam
    protonup-ng
  ];

  # Auto-install the Firefox theme on activation
  home.activation.installFirefoxTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Use the flake input directly
        THEME_PACKAGE="${inputs.firefox-everblush-theme.packages.${pkgs.system}.default}"

        if [ -e "$THEME_PACKAGE/share/firefox-addons/everblush-firefox-theme.xpi" ]; then
          mkdir -p $HOME/.local/bin
          cat > $HOME/.local/bin/install-firefox-everblush-theme << EOF
    #!/usr/bin/env bash

    echo "Everblush Firefox Theme Installer"
    echo "=================================="
    echo ""

    # Path to the XPI file
    XPI_PATH="$THEME_PACKAGE/share/firefox-addons/everblush-firefox-theme.xpi"

    echo "Theme file is located at: \$XPI_PATH"
    echo ""
    echo "To install the theme permanently:"
    echo "1. Open Firefox"
    echo "2. Go to about:addons (or click the menu button and select 'Add-ons and Themes')"
    echo "3. Click the gear icon in the top-right"
    echo "4. Select 'Install Add-on From File...'"
    echo "5. Navigate to and select: \$XPI_PATH"
    echo "6. Click 'Add' when prompted"
    echo ""
    echo "Would you like to open Firefox now? (y/n)"
    read -r OPEN_FIREFOX

    if [[ \$OPEN_FIREFOX =~ ^[Yy]\$ ]]; then
      firefox "about:addons" &
    fi
    EOF
          chmod +x $HOME/.local/bin/install-firefox-everblush-theme

          echo "Firefox Everblush theme package installed."
          echo "To install the theme in Firefox, run: install-firefox-everblush-theme"
        else
          echo "Warning: Firefox Everblush theme package not found at expected path."
        fi
  '';
}
