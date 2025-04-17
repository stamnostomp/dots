# modules/home/colors.nix
{ config, lib, pkgs, ... }:

let
  # Import the colors from the user's theme
  colorsDef = import ../../home/stamno/theme/colors.nix;
in
{
  # Make colors available globally to other modules
  options.my-colors = lib.mkOption {
    type = lib.types.attrs;
    default = colorsDef.colors;
    description = "Global color scheme for all modules";
  };

  config = {
    # This makes colors available as `config.my-colors` in all modules
    my-colors = colorsDef.colors;
  };
}
