{
  description = "Everblush GTK theme — Colloid compiled with the Everblush color palette";

  # The old Everblush/gtk (phocus) theme only styles common GTK3 widgets, which
  # left complex apps (KiCad, OrcaSlicer, other wxWidgets UIs) half-broken.
  # Colloid is a complete GTK3/GTK4/libadwaita theme whose colors all come from
  # one palette file, so we build it with the Everblush palette instead and
  # install it under the name "Everblush".

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
          everblush-gtk = pkgs.colloid-gtk-theme.overrideAttrs (old: {
            pname = "everblush-gtk";

            # Replace Colloid's default palette before the css is compiled.
            postPatch = (old.postPatch or "") + ''
              cp ${./everblush-palette.scss} src/sass/_color-palette-default.scss
            '';

            installPhase = ''
              runHook preInstall

              name= HOME="$TMPDIR" ./install.sh \
                --name Everblush \
                --color dark \
                --dest $out/share/themes

              # The theme directory name is what GTK_THEME / gtk-theme-name
              # match against, so rename "Everblush-Dark" to plain "Everblush".
              mv $out/share/themes/Everblush-Dark $out/share/themes/Everblush
              sed -i "s/Everblush-Dark/Everblush/g" $out/share/themes/Everblush/index.theme

              # xfwm4-only hdpi variants; not needed and they'd clutter theme pickers
              rm -rf $out/share/themes/Everblush-Dark-hdpi $out/share/themes/Everblush-Dark-xhdpi

              jdupes --quiet --link-soft --recurse $out/share

              runHook postInstall
            '';

            meta = old.meta // {
              description = "Colloid GTK theme built with the Everblush color palette";
            };
          });

          default = everblush-gtk;
        };
      }
    );
}
