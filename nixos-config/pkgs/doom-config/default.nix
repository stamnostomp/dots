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
    # You can use a specific commit or branch
    rev = "main";
    # You'll need to replace this with the actual hash after first trying to build
    # If you don't know the hash, use a placeholder and Nix will tell you the correct hash
    sha256 = lib.fakeSha256;
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
