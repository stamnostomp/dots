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

    repoUrl = mkOption {
      type = types.str;
      default = "https://github.com/stamnostomp/doom-d";
      description = "URL of your Doom config repository";
    };
  };

  config = mkIf cfg.enable {
    # Install Emacs with native compilation and wayland support
    programs.emacs = {
      enable = true;
      package = pkgs.emacsNativeComp;
    };

    # Set up environment variables
    home.sessionVariables = {
      EDITOR = "emacsclient -c";
      VISUAL = "emacsclient -c";
      ALTERNATE_EDITOR = "emacs";
      DOOMDIR = "${config.home.homeDirectory}/.doom.d";
      DOOMLOCALDIR = "${config.home.homeDirectory}/.doom-local";
    };

    # Doom-specific environment
    home.sessionPath = [
      "${config.home.homeDirectory}/.emacs.d/bin"
    ];

    # Essential packages (kept the same)
    home.packages = with pkgs; [
      # Core dependencies
      git
      ripgrep
      fd

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
      nil
      nixfmt-rfc-style
      shellcheck
      shfmt

      # Docker tools
      dockfmt

      # LSP and npm
      nodejs
      nodePackages.npm

      # C# development
      csharpier

      # Haskell development
      haskell-language-server
      haskellPackages.hoogle
      cabal-install
      ghc

      # Elm development
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-language-server
      elmPackages.elm-test

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

    # Setup activation script to clone/sync Doom configuration
    home.activation = {
      doomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        PATH=${pkgs.git}/bin:${pkgs.emacs-pgtk}/bin:$PATH

        # Clone or update Doom Emacs if needed
        if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
          $DRY_RUN_CMD git clone --depth 1 https://github.com/doomemacs/doomemacs ${config.home.homeDirectory}/.emacs.d
        fi

        # Remove existing .doom.d if it exists and clone fresh from repo
        if [ -d "${config.home.homeDirectory}/.doom.d" ]; then
          $DRY_RUN_CMD rm -rf ${config.home.homeDirectory}/.doom.d
        fi
        $DRY_RUN_CMD git clone ${cfg.repoUrl} ${config.home.homeDirectory}/.doom.d

        # Ensure Doom binary is executable
        if [ -f "${config.home.homeDirectory}/.emacs.d/bin/doom" ]; then
          $DRY_RUN_CMD chmod +x ${config.home.homeDirectory}/.emacs.d/bin/doom
        fi

        # Skip the doom sync for now, we'll do it in the wrapper
        # if [ -z "$DRY_RUN_CMD" ]; then
        #   rm -rf ${config.home.homeDirectory}/.doom-local
        #   ${config.home.homeDirectory}/.emacs.d/bin/doom -y sync
        # fi
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

    # Create Emacs wrapper script with improved sync handling
    home.file.".local/bin/emacs-wrapper" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Emacs wrapper to ensure proper environment

        # Set necessary environment variables
        export PATH="${config.home.homeDirectory}/.emacs.d/bin:${pkgs.emacs-pgtk}/bin:$PATH"
        export DOOMDIR="${config.home.homeDirectory}/.doom.d"
        export DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local"
        export EMACS="${pkgs.emacs-pgtk}/bin/emacs"

        # Check if Doom is properly installed/synced
        if [ ! -d "${config.home.homeDirectory}/.doom-local" ] || [ ! -f "${config.home.homeDirectory}/.doom-local/init.el" ]; then
          echo "Doom appears to be not properly installed. Running doom sync..."
          ${config.home.homeDirectory}/.emacs.d/bin/doom -y sync
        fi

        # Launch Emacs
        exec ${pkgs.emacs-pgtk}/bin/emacs "$@"
      '';
    };

    # Create Emacs service
    services.emacs = {
      enable = true;
      client.enable = true;
    };

    # Configure fontconfig
    fonts.fontconfig.enable = true;
  };
}
