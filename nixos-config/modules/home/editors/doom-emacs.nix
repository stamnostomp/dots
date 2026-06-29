# modules/home/editors/doom-emacs.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.doom-emacs;
in
{
  options.modules.doom-emacs = {
    enable = mkEnableOption "Doom Emacs configuration";

    configPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Gits/doom-d";
      description = "Path to your local Doom config directory (symlinked to ~/.doom.d)";
    };
  };

  config = mkIf cfg.enable {
    # Install Emacs with native compilation and wayland support
    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
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
      nixfmt
      nil

      #vterm comp
      libtool
      claude-code
      cmake
      gnumake
      gcc

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
      nodejs

      # C# development
      csharpier

      # Haskell development
      haskell-language-server
      haskellPackages.hoogle
      haskellPackages.ormolu
      haskellPackages.stylish-haskell
      cabal-install
      ghc

      # TidalCycles live coding
      (symlinkJoin {
        name = "supercollider-pipewire";
        paths = [ supercollider-with-sc3-plugins ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/sclang \
            --prefix LD_LIBRARY_PATH : "${pipewire.jack}/lib"
          wrapProgram $out/bin/scsynth \
            --prefix LD_LIBRARY_PATH : "${pipewire.jack}/lib"
        '';
      })
      (writeShellScriptBin "tidal-ghci" ''
        exec ${(haskellPackages.ghcWithPackages (hpkgs: [hpkgs.tidal]))}/bin/ghci "$@"
      '')

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
      #nodePackages.purescript-language-server
      #nodePackages.purs-tidy

      # Rust development
      rust-analyzer
      rustc
      cargo

      # Web development
      html-tidy

      # Clipboard and input simulation for Wayland (for emacs-everywhere)
      wl-clipboard
      wtype

      # Dirvish preview dependencies
      vips # vipsthumbnail for image previews
      ffmpegthumbnailer # video thumbnails
      poppler-utils # pdftoppm for PDF previews
      p7zip # 7z for archive previews
      mediainfo # audio file metadata
      imagemagick # magick for font previews
    ];

    # Setup activation script to clone Doom Emacs and symlink local doom config
    # This allows updating doom config without rebuilding the system
    home.activation = {
      doomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "Starting Doom Emacs setup..."

        # Set up environment
        export PATH=${pkgs.git}/bin:${pkgs.emacs-pgtk}/bin:${pkgs.nix}/bin:$PATH
        export DOOMDIR="${config.home.homeDirectory}/.doom.d"
        export DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local"
        export NIX_PATH="nixpkgs=${pkgs.path}"

        # Clone Doom Emacs if needed
        if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
          echo "Cloning Doom Emacs..."
          $DRY_RUN_CMD git clone --depth 1 https://github.com/doomemacs/doomemacs ${config.home.homeDirectory}/.emacs.d || {
            echo "Failed to clone Doom Emacs"
            exit 1
          }
        else
          echo "Doom Emacs already cloned"
        fi

        # Create symlink to local doom config if needed
        if [ -L "${config.home.homeDirectory}/.doom.d" ]; then
          CURRENT_TARGET=$(readlink "${config.home.homeDirectory}/.doom.d")
          if [ "$CURRENT_TARGET" != "${cfg.configPath}" ]; then
            echo "Updating symlink to point to ${cfg.configPath}..."
            $DRY_RUN_CMD rm ${config.home.homeDirectory}/.doom.d
            $DRY_RUN_CMD ln -s ${cfg.configPath} ${config.home.homeDirectory}/.doom.d
          else
            echo "Symlink already points to ${cfg.configPath}"
          fi
        elif [ -d "${config.home.homeDirectory}/.doom.d" ]; then
          echo "Warning: ~/.doom.d is a directory, not a symlink"
          echo "Remove it manually and rebuild if you want to use the symlink approach"
        else
          echo "Creating symlink to ${cfg.configPath}..."
          $DRY_RUN_CMD ln -s ${cfg.configPath} ${config.home.homeDirectory}/.doom.d
        fi

        # Ensure Doom binary is executable
        if [ -f "${config.home.homeDirectory}/.emacs.d/bin/doom" ]; then
          $DRY_RUN_CMD chmod +x ${config.home.homeDirectory}/.emacs.d/bin/doom
          echo "Made Doom binary executable"
        else
          echo "Warning: Doom binary not found at expected location"
        fi

        # Run doom sync only on initial setup (when .doom-local doesn't have init.el)
        if [ -z "$DRY_RUN_CMD" ]; then
          mkdir -p ${config.home.homeDirectory}/.doom-local

          if [ ! -f "${config.home.homeDirectory}/.doom-local/init.el" ]; then
            echo "Running initial doom sync..."

            if DOOMDIR="${config.home.homeDirectory}/.doom.d" \
               DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local" \
               NIX_PATH="nixpkgs=${pkgs.path}" \
               ${config.home.homeDirectory}/.emacs.d/bin/doom sync 2>&1; then
              echo "Doom sync completed successfully"
            else
              DOOM_EXIT_CODE=$?
              echo "Warning: Doom sync returned exit code $DOOM_EXIT_CODE"

              if [ -f "${config.home.homeDirectory}/.doom-local/init.el" ]; then
                echo "Doom appears to be properly configured despite exit code"
              else
                echo "Error: Doom sync failed - init.el not found"
                echo "Running doom doctor for diagnostics..."
                DOOMDIR="${config.home.homeDirectory}/.doom.d" \
                DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local" \
                NIX_PATH="nixpkgs=${pkgs.path}" \
                ${config.home.homeDirectory}/.emacs.d/bin/doom doctor || true
                echo "Continuing despite doom sync issues..."
              fi
            fi
          else
            echo "Doom already initialized, skipping doom sync"
            echo "Run 'doom sync' manually after updating your config"
          fi
        else
          echo "Dry run mode - skipping doom sync"
        fi

        echo "Doom Emacs setup completed"
      '';
    };

    # Create XDG desktop entry
    xdg.desktopEntries.emacs = {
      name = "Emacs";
      genericName = "Text Editor";
      exec = "emacsclient -c %F";
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
          echo "nix develop basic test passed"
        else
          echo "nix develop basic test failed"
        fi

        echo
        echo "Testing fish in nix develop:"
        if nix develop --command fish -c 'echo "fish works in nix-shell"' 2>/dev/null; then
          echo "fish in nix develop test passed"
        else
          echo "fish in nix develop test failed"
        fi

        echo
        echo "Fish configuration check:"
        if [ -f "$HOME/.config/fish/config.fish" ]; then
          echo "Fish config exists"
        else
          echo "Fish config not found"
        fi

        echo
        echo "=== End Debug Information ==="
      '';
    };

    # Create Emacs service with improved environment
    services.emacs = {
      enable = true;
      client.enable = true;
    };

    # Add Doom environment variables to the emacs systemd service
    systemd.user.services.emacs.Service.Environment = [
      "DOOMDIR=${config.home.homeDirectory}/.doom.d"
      "DOOMLOCALDIR=${config.home.homeDirectory}/.doom-local"
    ];

    # Configure fontconfig
    fonts.fontconfig.enable = true;
  };
}
