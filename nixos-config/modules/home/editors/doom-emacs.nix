# modules/home/editors/doom-emacs.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.doom-emacs;
in
{
  options.modules.doom-emacs = {
    enable = mkEnableOption "Doom Emacs configuration";

    # The repoUrl option is no longer used but kept for backward compatibility
    repoUrl = mkOption {
      type = types.str;
      default = "https://github.com/stamnostomp/doom-d";
      description = "URL of your Doom config repository (deprecated, now using packaged config)";
    };
  };

  config = mkIf cfg.enable {
    # Install Emacs with native compilation and wayland support
    programs.emacs = {
      enable = true;
      package = pkgs.emacsNativeComp;
    };

    # Set up environment variables - improved for nix-shell support
    home.sessionVariables = {
      EDITOR = "emacsclient -c";
      VISUAL = "emacsclient -c";
      ALTERNATE_EDITOR = "emacs";
      DOOMDIR = "${config.home.homeDirectory}/.doom.d";
      DOOMLOCALDIR = "${config.home.homeDirectory}/.doom-local";
      # Ensure nix commands work in Emacs shells
      NIX_PATH = "nixpkgs=${pkgs.path}";
    };

    # Doom-specific environment
    home.sessionPath = [
      "${config.home.homeDirectory}/.emacs.d/bin"
      "${pkgs.nix}/bin" # Ensure nix is in PATH
    ];

    # Essential packages (kept the same but added debugging tools)
    home.packages = with pkgs; [
      # Core dependencies
      git
      ripgrep
      fd

      # Nix development tools
      nix
      nixfmt-rfc-style
      nil

      #vterm comp
      libtool

      #spell checking
      ispell
      hunspell
      hunspellDicts.en_US

      # Essential fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      dina-font

      # Language support
      shellcheck
      shfmt

      # Docker tools
      dockfmt

      # LSP and npm
      #nodejs
      nodePackages.npm

      # C# development
      csharpier

      # Haskell development
      haskell-language-server
      haskellPackages.hoogle
      cabal-install
      ghc

      elmPackages.elm-format
      elmPackages.elm-language-server

      # Kotlin development
      ktlint

      # Markdown
      pandoc

      # PlantUML
      plantuml
      jdk
      graphviz

      # PureScript
      purescript
      nodePackages.purescript-language-server
      nodePackages.purs-tidy

      # Rust development
      rust-analyzer
      rustc
      cargo

      # Web development
      html-tidy
      nodePackages.stylelint
      nodePackages.js-beautify

      # Clipboard and window management (for everywhere)
      xclip
      xorg.xwininfo
      xdotool
    ];

    # Setup activation script to clone Doom Emacs and symlink the packaged config
    home.activation = {
      doomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        PATH=${pkgs.git}/bin:${pkgs.emacs-pgtk}/bin:${pkgs.nix}/bin:$PATH

        # Clone or update Doom Emacs if needed
        if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
          $DRY_RUN_CMD git clone --depth 1 https://github.com/doomemacs/doomemacs ${config.home.homeDirectory}/.emacs.d
        fi

        # Remove existing .doom.d if it exists and symlink the packaged config
        if [ -d "${config.home.homeDirectory}/.doom.d" ]; then
          $DRY_RUN_CMD rm -rf ${config.home.homeDirectory}/.doom.d
        fi

        # Create symlink to the packaged Doom config
        $DRY_RUN_CMD ln -sf ${
          inputs.doom-config.packages.${pkgs.system}.default
        } ${config.home.homeDirectory}/.doom.d

        # Ensure Doom binary is executable
        if [ -f "${config.home.homeDirectory}/.emacs.d/bin/doom" ]; then
          $DRY_RUN_CMD chmod +x ${config.home.homeDirectory}/.emacs.d/bin/doom
        fi

        # Run doom sync if not in dry run mode
        if [ -z "$DRY_RUN_CMD" ]; then
          # Make sure the directory exists first
          mkdir -p ${config.home.homeDirectory}/.doom-local
          # Run doom sync with important environment variables
          DOOMDIR="${config.home.homeDirectory}/.doom.d" \
          DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local" \
          NIX_PATH="nixpkgs=${pkgs.path}" \
          ${config.home.homeDirectory}/.emacs.d/bin/doom sync
        fi
      '';
    };

    # Create XDG desktop entry
    xdg.desktopEntries.emacs = {
      name = "Emacs";
      genericName = "Text Editor";
      exec = "${config.home.homeDirectory}/.local/bin/emacs-wrapper %F";
      terminal = false;
      categories = [
        "Development"
        "TextEditor"
      ];
      icon = "emacs";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    };

    # Create Emacs wrapper script with improved nix-shell support
    home.file.".local/bin/emacs-wrapper" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Emacs wrapper to ensure proper environment and nix-shell support

        # Set necessary environment variables
        export PATH="${config.home.homeDirectory}/.emacs.d/bin:${pkgs.emacs-pgtk}/bin:${pkgs.nix}/bin:$PATH"
        export DOOMDIR="${config.home.homeDirectory}/.doom.d"
        export DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local"
        export EMACS="${pkgs.emacs-pgtk}/bin/emacs"
        export NIX_PATH="nixpkgs=${pkgs.path}"

        # Ensure nix profile is sourced for proper nix command availability
        if [ -e "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]; then
          source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
        fi

        # Check if Doom is properly installed/synced
        if [ ! -d "${config.home.homeDirectory}/.doom-local" ] || [ ! -f "${config.home.homeDirectory}/.doom-local/init.el" ]; then
          echo "Doom appears to be not properly installed. Running doom sync..."
          DOOMDIR="${config.home.homeDirectory}/.doom.d" \
          DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local" \
          NIX_PATH="nixpkgs=${pkgs.path}" \
          ${config.home.homeDirectory}/.emacs.d/bin/doom sync
        fi

        # Launch Emacs with proper environment
        exec ${pkgs.emacs-pgtk}/bin/emacs "$@"
      '';
    };

    # Create debug script for nix-shell issues
    home.file.".local/bin/debug-emacs-nix.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Debug script for Emacs nix-shell issues

        echo "=== Emacs Nix-Shell Debug Information ==="
        echo

        echo "Current Environment Variables:"
        echo "INSIDE_EMACS: ''${INSIDE_EMACS:-"not set"}"
        echo "IN_NIX_SHELL: ''${IN_NIX_SHELL:-"not set"}"
        echo "NIX_SHELL_NAME: ''${NIX_SHELL_NAME:-"not set"}"
        echo "SHELL: ''${SHELL:-"not set"}"
        echo "TERM: ''${TERM:-"not set"}"
        echo "PWD: $(pwd)"
        echo

        echo "Available Commands:"
        echo "nix command: $(which nix || echo "not found")"
        echo "fish command: $(which fish || echo "not found")"
        echo "bash command: $(which bash || echo "not found")"
        echo

        echo "Testing nix develop:"
        echo "Attempting basic nix develop test..."
        if nix develop --command echo "nix develop works" 2>/dev/null; then
          echo "✅ nix develop basic test passed"
        else
          echo "❌ nix develop basic test failed"
        fi

        echo
        echo "Testing fish in nix develop:"
        if nix develop --command fish -c 'echo "fish works in nix-shell"' 2>/dev/null; then
          echo "✅ fish in nix develop test passed"
        else
          echo "❌ fish in nix develop test failed"
        fi

        echo
        echo "Fish configuration check:"
        if [ -f "$HOME/.config/fish/config.fish" ]; then
          echo "✅ Fish config exists"
        else
          echo "❌ Fish config not found"
        fi

        echo
        echo "=== End Debug Information ==="
      '';
    };

    # Create Emacs service with improved environment
    services.emacs = {
      enable = true;
      client.enable = true;
      # Set environment variables for the daemon
      extraOptions = [
        "--with-profile"
        "doom"
      ];
    };

    # Configure fontconfig
    fonts.fontconfig.enable = true;
  };
}
