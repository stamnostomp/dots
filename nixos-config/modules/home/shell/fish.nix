# modules/home/shell/fish.nix
{ config, lib, pkgs, ... }:

{
  # Fish shell configuration
  programs.fish = {
    enable = true;
    plugins = [
      { name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }
    ];

    interactiveShellInit = ''
      # Set environment variables
      set -gx GTK_THEME "Everblush"

      # Nix shell integration for fish
      function __fish_nix_shell_prompt
        if set -q IN_NIX_SHELL
          echo -n " (nix-shell)"
        end
      end

      # Add the nix-shell status to the prompt
      functions -c fish_prompt _old_fish_prompt
      function fish_prompt
        _old_fish_prompt
        __fish_nix_shell_prompt
      end
    '';
  };
}
