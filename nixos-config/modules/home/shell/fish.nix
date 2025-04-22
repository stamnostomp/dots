# modules/home/shell/fish.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Fish shell configuration
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }

      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "00c6cc762427efe08ac0bd0d1b1d12048d3ca727";
          sha256 = "1hrl22dd0aaszdanhvddvqz3aq40jp9zi2zn0v1hjnf7fx4bgpma";
        };
      }
    ];

    interactiveShellInit = lib.mkAfter ''
      # Nix development shell integration
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end

      # Handle nix develop shell transitions
      function __handle_nix_shell_enter --on-variable IN_NIX_SHELL
        if set -q IN_NIX_SHELL
          # We've entered a nix shell
          echo "Entered Nix development environment"
        end
      end
    '';

    shellAliases = {
      # ... your existing aliases
      "nix-develop" = "nix develop --command fish";
    };
  };
}
