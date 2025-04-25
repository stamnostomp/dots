# pkgs/doom-config/default.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "doom-config";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "stamnostomp";
    repo = "doom-d";
    # Using master instead of main branch
    rev = "master";
    # Replace this with the actual hash after the first build attempt fails
    # Nix will provide the correct hash in the error message
    sha256 = "sha256-KztD7kL46/qEfb0lAoqwPAm7CCz0QmfFEuKIZ/j9tYw=";
  };

  # No build step needed, we're just copying files
  dontBuild = true;

  installPhase = ''
    # Create the output directory
    mkdir -p $out

    # Copy all files from the repository
    cp -r ./* $out/
  '';

  meta = with lib; {
    description = "Personal Doom Emacs configuration";
    license = licenses.mit; # Adjust as needed
    platforms = platforms.all;
    maintainers = [ ];
  };
}
