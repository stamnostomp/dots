{
  description = "Fixed Orca Slicer with proper GTK settings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          orca-slicer-fixed = pkgs.callPackage ./default.nix { };
          default = orca-slicer-fixed;
        };
      }
    );
}
