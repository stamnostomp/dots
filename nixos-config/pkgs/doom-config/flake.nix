{
  description = "Personal Doom Emacs configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Add this new input to fetch your doom-d repository
    doom-d = {
      url = "github:stamnostomp/.doom-d"; # Your repo
      flake = false; # Not a flake itself
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      doom-d,
      ...
    }:
    let
      systems = [ "x86_64-linux" ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "doom-config";
            version = "1.0.0";

            # Use the doom-d input directly instead of fetchFromGitHub
            src = doom-d;

            # No build step needed, we're just copying files
            dontBuild = true;

            installPhase = ''
              # Create the output directory
              mkdir -p $out

              # Copy all files from the repository
              cp -r ./* $out/
            '';

            meta = with pkgs.lib; {
              description = "Personal Doom Emacs configuration";
              license = licenses.mit;
              platforms = platforms.all;
              maintainers = [ ];
            };
          };
        }
      );
    };
}
