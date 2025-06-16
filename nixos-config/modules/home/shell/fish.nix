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

      # Better nix-shell detection and integration
      function __nix_shell_prompt
        if set -q IN_NIX_SHELL
          if test "$IN_NIX_SHELL" = "pure"
            echo -n " (nix-shell-pure)"
          else if test "$IN_NIX_SHELL" = "impure"
            echo -n " (nix-shell)"
          else
            echo -n " (nix-shell)"
          end
        end
      end

      # Handle nix develop shell transitions
      function __handle_nix_shell_enter --on-variable IN_NIX_SHELL
        if set -q IN_NIX_SHELL
          # We've entered a nix shell
          if set -q INSIDE_EMACS
            echo "✅ Entered Nix development environment in Emacs"
          else
            echo "✅ Entered Nix development environment"
          end

          # Show available packages if buildInputs is set
          if set -q buildInputs
            echo "📦 Available packages: $buildInputs"
          end
        end
      end

      # Ensure nix-shell works properly in vterm
      if set -q INSIDE_EMACS
        # Make sure nix commands work in Emacs
        if test -e $HOME/.nix-profile/etc/profile.d/nix.sh
          # Source nix profile in bash compatibility mode
          bash -c "source $HOME/.nix-profile/etc/profile.d/nix.sh; env" | while read line
            set -l parts (string split "=" $line)
            if test (count $parts) -ge 2
              set -gx $parts[1] (string join "=" $parts[2..-1])
            end
          end
        end
      end

      # SSH agent setup
      if test -z "$SSH_AUTH_SOCK"
        eval (ssh-agent -c) > /dev/null
        ssh-add ~/.ssh/id_ed25519 2>/dev/null
      end

      # Custom function for nix develop with fish
      function nix-develop
        if test (count $argv) -gt 0
          nix develop $argv --command fish
        else
          nix develop --command fish
        end
      end

      # Alias for convenience
      alias nd="nix-develop"
    '';

    shellAliases = {
      # Nix aliases
      "nix-develop" = "nix develop --command fish";
      "nd" = "nix develop --command fish";
      "nix-shell" = "nix-shell --command fish";

      # Other useful aliases
      "ll" = "ls -la";
      "la" = "ls -la";
      "l" = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
      "grep" = "rg";
    };
  };
}
