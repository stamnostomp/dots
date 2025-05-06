{
  description = "Everblush GTK Theme with Selection Highlighting Fix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
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

            buildPhase = ''
              make
            '';

            installPhase = ''
              # Create theme directory
              mkdir -p $out/share/themes/Everblush

              # Copy all built theme files
              cp -r gtk-* $out/share/themes/Everblush/ || true
              cp -r assets $out/share/themes/Everblush/ || true
              cp -r index.theme $out/share/themes/Everblush/ || true

              # Define our selection CSS fix
              SELECTION_CSS="
              /* GTK Selection Highlighting Fix */

              /* Generic selection highlight rules */
              ::-moz-selection {
                background-color: #67b0e8 !important; /* Blue from Everblush */
                color: #141b1e !important;           /* Background from Everblush */
              }

              ::selection {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* GTK specific selection highlight */
              *:selected,
              *:focus:selected {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* Text view and other widget selection */
              textview text:selected,
              textview text:selected:focus,
              textview text selection,
              entry selection,
              label selection,
              .view:selected,
              .view:selected:focus,
              .view text:selected,
              iconview:selected,
              iconview:selected:focus,
              flowbox flowboxchild:selected,
              entry:selected,
              modelbutton.flat:selected,
              treeview.view:selected,
              treeview.view:selected:focus,
              row:selected,
              calendar:selected,
              .gedit-document-panel-document-row:selected {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* For Thunar/PCManFM specific fixes */
              .thunar .view:selected,
              .pcmanfm .view:selected,
              .thunar .sidebar .view:selected,
              .pcmanfm .sidebar .view:selected {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* File browsers selection */
              filechooser .view:selected,
              filechooser .view:selected:focus {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* Terminal selection - often needs special handling */
              vte-terminal selection {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* Firefox and Chrome URL bar selection */
              entry selection,
              entry:selected {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* Menu item selection */
              menuitem:hover,
              menuitem:selected {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* Make sure combo box selections are visible */
              combobox *:selected,
              combobox *:focus:selected {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }

              /* Force stronger selection for list items */
              list row:selected,
              list row:selected:focus {
                background-color: #67b0e8 !important;
                color: #141b1e !important;
              }
              "

              # Add the selection CSS to GTK3
              if [ -d "$out/share/themes/Everblush/gtk-3.0" ]; then
                # Check if gtk.css exists
                if [ -f "$out/share/themes/Everblush/gtk-3.0/gtk.css" ]; then
                  echo "$SELECTION_CSS" >> $out/share/themes/Everblush/gtk-3.0/gtk.css
                else
                  echo "$SELECTION_CSS" > $out/share/themes/Everblush/gtk-3.0/gtk.css
                fi
              else
                # Create the directory and file if they don't exist
                mkdir -p $out/share/themes/Everblush/gtk-3.0
                echo "$SELECTION_CSS" > $out/share/themes/Everblush/gtk-3.0/gtk.css
              fi

              # Add selection CSS for GTK4 (create directory and file if needed)
              mkdir -p $out/share/themes/Everblush/gtk-4.0
              echo "$SELECTION_CSS" > $out/share/themes/Everblush/gtk-4.0/gtk.css

              # Create a GTK2 version too, just to be safe
              if [ -d "$out/share/themes/Everblush/gtk-2.0" ]; then
                if [ -f "$out/share/themes/Everblush/gtk-2.0/gtkrc" ]; then
                  # Add a comment since GTK2 doesn't support these CSS rules
                  echo "# Selection highlighting for GTK2 is handled by the GTK engine" >> $out/share/themes/Everblush/gtk-2.0/gtkrc
                fi
              fi

              # Ensure we have a valid theme structure
              touch $out/share/themes/Everblush/index.theme
            '';

            meta = with pkgs.lib; {
              description = "Everblush GTK Theme with improved selection highlighting";
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
