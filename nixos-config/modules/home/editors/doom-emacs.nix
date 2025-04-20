# modules/home/editors/doom-emacs.nix
{ config, lib, pkgs, ... }:

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
      package = pkgs.emacs-pgtk;
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
    
    # Essential packages for Doom to function
    home.packages = with pkgs; [
      # Core dependencies
      git
      ripgrep
      fd
      
      # Essential fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      
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
      doomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        PATH=${pkgs.git}/bin:$PATH
        
        # Clone or update Doom Emacs if needed
        if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
          $DRY_RUN_CMD git clone --depth 1 https://github.com/doomemacs/doomemacs ${config.home.homeDirectory}/.emacs.d
        fi
        
        # Clone or update user Doom configuration
        if [ ! -d "${config.home.homeDirectory}/.doom.d" ]; then
          $DRY_RUN_CMD git clone ${cfg.repoUrl} ${config.home.homeDirectory}/.doom.d
        else
          # Pull latest changes if it's a git repository
          if [ -d "${config.home.homeDirectory}/.doom.d/.git" ]; then
            $DRY_RUN_CMD cd ${config.home.homeDirectory}/.doom.d && git pull || true
          fi
        fi
        
        # Ensure Doom binary is executable
        if [ -f "${config.home.homeDirectory}/.emacs.d/bin/doom" ]; then
          $DRY_RUN_CMD chmod +x ${config.home.homeDirectory}/.emacs.d/bin/doom
        fi
      '';
    };
    
    # Create XDG desktop entry
    xdg.desktopEntries.emacs = {
      name = "Emacs";
      genericName = "Text Editor";
      exec = "${config.home.profileDirectory}/bin/emacs-wrapper %F";
      terminal = false;
      categories = [ "Development" "TextEditor" ];
      icon = "emacs";
      mimeType = [ "text/english" "text/plain" "text/x-makefile" "text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc" "text/x-java" "text/x-moc" "text/x-pascal" "text/x-tcl" "text/x-tex" "application/x-shellscript" "text/x-c" "text/x-c++" ];
    };
    
    # Create Emacs wrapper script
    home.file.".local/bin/emacs-wrapper" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Emacs wrapper to ensure proper environment
        
        # Set necessary environment variables
        export PATH="${config.home.homeDirectory}/.emacs.d/bin:$PATH"
        export DOOMDIR="${config.home.homeDirectory}/.doom.d"
        export DOOMLOCALDIR="${config.home.homeDirectory}/.doom-local"
        
        # Run doom sync if the configuration changed
        if [ -f "${config.home.homeDirectory}/.doom.d/.git/FETCH_HEAD" ]; then
          LAST_FETCH=$(stat -c %Y "${config.home.homeDirectory}/.doom.d/.git/FETCH_HEAD")
          CURRENT_TIME=$(date +%s)
          # If last fetch was more than 24 hours ago, sync
          if [ $((CURRENT_TIME - LAST_FETCH)) -gt 86400 ]; then
            ${config.home.homeDirectory}/.emacs.d/bin/doom sync &
          fi
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
