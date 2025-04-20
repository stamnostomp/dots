# modules/home/editors/doom-emacs.nix
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.doom-emacs;
in
{
  options.modules.doom-emacs = {
    enable = mkEnableOption "Doom Emacs configuration";
    
    doomPrivateDir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.doom.d";
      description = "Directory for your private Doom Emacs configuration";
    };
    
    doomRepoUrl = mkOption {
      type = types.str;
      default = "https://github.com/doomemacs/doomemacs";
      description = "URL of the Doom Emacs repository";
    };
    
    userRepoUrl = mkOption {
      type = types.str;
      default = "https://github.com/stamnostomp/doom-d";
      description = "URL of your Doom Emacs private configuration";
    };
  };

  config = mkIf cfg.enable {
    # Install Emacs with native compilation and wayland support
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = epkgs: with epkgs; [
        vterm
        # Add any additional Emacs packages here
      ];
    };
    
    # Set up environment variables for shell
    home.sessionVariables = {
      DOOMDIR = cfg.doomPrivateDir;
      DOOMLOCALDIR = "${config.home.homeDirectory}/.doom-local";
    };
    
    # Add all the dependencies required by Doom Emacs
    home.packages = with pkgs; [
      # Core dependencies
      git
      ripgrep
      fd
      coreutils
      
      # CLI utilities mentioned in error
      xclip
      xdotool
      xorg.xwininfo
      
      # Tool dependencies
      cmake
      nodePackages.npm
      
      # Language servers and tooling
      nodePackages.typescript-language-server # For JS/TS
      nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
      nodePackages.bash-language-server
      nil # Nix language server
      rust-analyzer
      rustc
      cargo
      cabal-install
      ghc
      haskell-language-server
      haskellPackages.hoogle
      kotlin-language-server
      ktlint
      dotnet-sdk # For C#
      omnisharp-roslyn
      plantuml
      openjdk # For PlantUML
      graphviz # For PlantUML
      purescript
      shellcheck
      shfmt
      
      # For web development
      nodePackages.prettier
      nodePackages.stylelint
      nodePackages.js-beautify
    ];
    
    # Let's configure the terminal to handle Fish correctly
    programs.bash.initExtra = ''
      # Ensure Emacs can work with Fish shell
      [ -n "$INSIDE_EMACS" ] && export SHELL=${pkgs.bash}/bin/bash
    '';
    
    programs.fish.interactiveShellInit = ''
      # Ensure Emacs can work with Fish shell
      if set -q INSIDE_EMACS
          set -gx SHELL ${pkgs.bash}/bin/bash
      end
    '';
    
    # Clone and set up Doom Emacs
    home.activation.installDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Use git from Nix store
      PATH=${pkgs.git}/bin:$PATH
      
      # Clone Doom Emacs if it doesn't exist
      if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
        $DRY_RUN_CMD git clone --depth 1 ${cfg.doomRepoUrl} ${config.home.homeDirectory}/.emacs.d
      else
        $DRY_RUN_CMD echo "Doom Emacs already installed, skipping clone"
      fi
      
      # Clone your personal config
      if [ ! -d "${cfg.doomPrivateDir}" ]; then
        $DRY_RUN_CMD git clone ${cfg.userRepoUrl} ${cfg.doomPrivateDir}
      else
        $DRY_RUN_CMD echo "Doom config already cloned, skipping"
      fi
      
      # Set up shell file for Emacs
      $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.doom.d
      $DRY_RUN_CMD echo '(setq shell-file-name "${pkgs.bash}/bin/bash")' > ${config.home.homeDirectory}/.doom.d/shells.el
      
      # Make sure Emacs and other required binaries are in PATH
      PATH=${pkgs.emacs-pgtk}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH
      
      # Install Doom Emacs
      if [ ! -f "${config.home.homeDirectory}/.emacs.d/bin/doom" ]; then
        $DRY_RUN_CMD ${config.home.homeDirectory}/.emacs.d/bin/doom install --no-config --no-env
      else
        $DRY_RUN_CMD echo "Doom Emacs already installed, syncing..."
        $DRY_RUN_CMD ${config.home.homeDirectory}/.emacs.d/bin/doom sync
      fi
    '';
    
    # Create a desktop file for Doom Emacs
    xdg.desktopEntries.doom-emacs = {
      name = "Doom Emacs";
      comment = "Doom Emacs Text Editor";
      icon = "emacs";
      exec = "emacs";
      categories = [ "Development" "TextEditor" ];
      terminal = false;
      mimeType = [ "text/plain" ];
    };
  };
}
