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
    settings = {
      user = {
        name = "stamnostomp";
        email = "stamno@pm.me";
      };
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
    inputs.firefox-everblush-theme.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Development tools
    git
    ripgrep
    htop
    btop
    localsend

    # File managers
    pcmanfm # Lightweight GTK+ file manager
    thunar
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
    godot

    # CAD
    #freecad-wayland
    freecad
    kicad
    #
    #    openscad

    # 3D printing - using standard orca-slicer from nixpkgs
    orca-slicer
    prusa-slicer

    # VPN
    protonvpn-gui

    # Wine
    bottles
  ];

  # Auto-install the Firefox theme on activation
  home.activation.installFirefoxTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Use the flake input directly
        THEME_PACKAGE="${
          inputs.firefox-everblush-theme.packages.${pkgs.stdenv.hostPlatform.system}.default
        }"

        # Create the script in the user's bin directory
        mkdir -p $HOME/.local/bin
        cat > $HOME/.local/bin/install-firefox-everblush-theme << EOF
    #!/usr/bin/env bash

    echo "Everblush Firefox Theme Installer"
    echo "=================================="
    echo ""

    # Find Firefox profile directory
    if [ -d "\$HOME/.mozilla/firefox" ]; then
        FIREFOX_DIR="\$HOME/.mozilla/firefox"

        # Find profiles
        PROFILES=\$(grep -E "^Path=" "\$FIREFOX_DIR/profiles.ini" | cut -d'=' -f2)

        if [ -z "\$PROFILES" ]; then
            echo "Could not find any Firefox profiles."
            exit 1
        fi

        # If more than one profile, let user choose
        if [ \$(echo "\$PROFILES" | wc -l) -gt 1 ]; then
            echo "Found multiple Firefox profiles:"
            PS3="Select a profile to install the theme (number): "
            select PROFILE in \$PROFILES; do
                if [ -n "\$PROFILE" ]; then
                    PROFILE_PATH="\$FIREFOX_DIR/\$PROFILE"
                    break
                fi
            done
        else
            PROFILE="\$PROFILES"
            PROFILE_PATH="\$FIREFOX_DIR/\$PROFILE"
        fi

        echo "Using profile: \$PROFILE_PATH"

        # Create chrome directory if it doesn't exist
        mkdir -p "\$PROFILE_PATH/chrome"

        # Install theme files
        echo "Installing theme files..."

        # Install user.js preferences
        if [ -f "\$PROFILE_PATH/user.js" ]; then
            # Append our preferences without overwriting the existing ones
            cat "$THEME_PACKAGE/share/firefox-everblush-theme/user.js" >> "\$PROFILE_PATH/user.js"
            echo "Added theme preferences to existing user.js"
        else
            # Create new user.js
            cp "$THEME_PACKAGE/share/firefox-everblush-theme/user.js" "\$PROFILE_PATH/user.js"
            echo "Created new user.js with theme preferences"
        fi

        # Install CSS files
        cp "$THEME_PACKAGE/share/firefox-everblush-theme/chrome/userChrome.css" "\$PROFILE_PATH/chrome/"
        cp "$THEME_PACKAGE/share/firefox-everblush-theme/chrome/userContent.css" "\$PROFILE_PATH/chrome/"

        # Set proper permissions
        chmod 644 "\$PROFILE_PATH/chrome/userChrome.css"
        chmod 644 "\$PROFILE_PATH/chrome/userContent.css"
        chmod 644 "\$PROFILE_PATH/user.js"

        echo "Theme installed successfully!"
        echo ""
        echo "Please start Firefox now to see the new theme."
        echo "If the theme doesn't apply, check about:config and make sure"
        echo "toolkit.legacyUserProfileCustomizations.stylesheets is set to true."

    else
        echo "Firefox profile directory not found."
        echo "Please make sure Firefox is installed and has been run at least once."
        exit 1
    fi
    EOF
        chmod +x $HOME/.local/bin/install-firefox-everblush-theme
  '';
}
