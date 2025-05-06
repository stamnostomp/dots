{
  description = "Everblush GTK Theme with Transparency Support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          everblush-gtk = pkgs.stdenv.mkDerivation {
            pname = "everblush-gtk";
            version = "1.0.0";

            src = pkgs.fetchFromGitHub {
              owner = "Everblush";
              repo = "gtk";
              rev = "main";
              sha256 = "sha256-bVMwXCNncv47Ksjyq6pc1EU4Ede6PCefd1+I62wM0Lk=";
            };

            nativeBuildInputs = with pkgs; [
              gnumake
              nodePackages.sass
            ];

            propagatedUserEnvPkgs = with pkgs; [
              gtk-engine-murrine
              gtk_engines
            ];

            # We'll create the files in the right place directly
            buildPhase = ''
              make
            '';

            installPhase = ''
              mkdir -p $out/share/themes/Everblush
              cp -r gtk-* $out/share/themes/Everblush/
              cp -r assets $out/share/themes/Everblush/ || true
              cp -r index.theme $out/share/themes/Everblush/ || true

              # Add our transparency fixes
              cat ${./transparency-fixes/gtk-3.0/gtk.css} >> $out/share/themes/Everblush/gtk-3.0/gtk.css
              cat ${./transparency-fixes/gtk-4.0/gtk.css} >> $out/share/themes/Everblush/gtk-4.0/gtk.css
            '';

            meta = with pkgs.lib; {
              description = "Everblush GTK Theme with transparency support";
              homepage = "https://github.com/Everblush/gtk";
              license = licenses.mit;
              platforms = platforms.all;
              maintainers = [ ];
            };
          };

          default = everblush-gtk;
        };
      }
    );
}
