# modules/home/cad/kicad.nix
#
# Declaratively manage KiCad's *global* symbol/footprint library tables.
#
# Why this exists:
#   KiCad only writes ~/.config/kicad/<ver>/{sym,fp}-lib-table on first run and
#   never refreshes them. After a KiCad update the old tables keep pointing at a
#   garbage-collected /nix/store path (and can even be left `(disabled)`), so the
#   symbol/footprint browser shows *no* libraries. This module regenerates those
#   tables from the packaged libraries on every home-manager switch.
#
# The URIs use ${KICADxx_SYMBOL_DIR} / ${KICADxx_FOOTPRINT_DIR}, the env vars the
# kicad wrapper always exports, so the tables never go stale across GC/upgrades.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  kicad = pkgs.kicad;

  # e.g. "10.0" -> config dir; "10" -> env-var prefix (KICAD10_SYMBOL_DIR)
  verDir = lib.versions.majorMinor kicad.version;
  verMajor = lib.versions.major kicad.version;

  symbols = kicad.libraries.symbols;
  footprints = kicad.libraries.footprints;

  # Build both global lib-tables from the packaged libraries.
  libTables = pkgs.runCommandLocal "kicad-global-lib-tables" { } ''
    mkdir -p "$out"

    symlibs="${symbols}/share/kicad/symbols"
    fplibs="${footprints}/share/kicad/footprints"

    {
      echo '(sym_lib_table'
      echo '  (version 7)'
      for f in "$symlibs"/*.kicad_sym; do
        name=$(basename "$f" .kicad_sym)
        printf '  (lib (name "%s") (type "KiCad") (uri "''${KICAD${verMajor}_SYMBOL_DIR}/%s.kicad_sym") (options "") (descr ""))\n' "$name" "$name"
      done
      echo ')'
    } > "$out/sym-lib-table"

    {
      echo '(fp_lib_table'
      echo '  (version 7)'
      for d in "$fplibs"/*.pretty; do
        name=$(basename "$d" .pretty)
        printf '  (lib (name "%s") (type "KiCad") (uri "''${KICAD${verMajor}_FOOTPRINT_DIR}/%s.pretty") (options "") (descr ""))\n' "$name" "$name"
      done
      echo ')'
    } > "$out/fp-lib-table"
  '';

  cfgDir = "${config.xdg.configHome}/kicad/${verDir}";
in
{
  home.packages = [ kicad ];

  # Install writable copies (KiCad normalizes/rewrites these files), overwriting
  # any stale table on every switch. Manual global-library edits made via the GUI
  # will be reset on the next rebuild — that's the point of managing them here.
  home.activation.kicadLibTables = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg cfgDir}
    run install -m 644 ${libTables}/sym-lib-table ${lib.escapeShellArg "${cfgDir}/sym-lib-table"}
    run install -m 644 ${libTables}/fp-lib-table  ${lib.escapeShellArg "${cfgDir}/fp-lib-table"}
  '';
}
