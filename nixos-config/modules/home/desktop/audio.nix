# modules/home/desktop/audio.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Create a script to launch pavucontrol with proper theme environment
  home.file.".local/bin/pavucontrol-launch" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      export GTK_THEME="Everblush"
      export GTK2_RC_FILES="${config.xdg.configHome}/gtk-2.0/gtkrc:${config.home.homeDirectory}/.gtkrc-2.0"
      export XDG_DATA_DIRS="${config.home.profileDirectory}/share:$XDG_DATA_DIRS"

      exec ${pkgs.pavucontrol}/bin/pavucontrol "$@"
    '';
  };

  # Add pavucontrol package
  home.packages = with pkgs; [
    pavucontrol
  ];
}
