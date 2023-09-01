{ self, lib, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
  ;

  inherit (flake-parts-lib)
    mkSubmoduleOptions
  ;

in
{
  options = {
    flake = mkSubmoduleOptions {
      homeModules = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
        apply =
          lib.mapAttrs
            (k: v: {
              _file = "${toString self.outPath}/flake.nix#homeModules.${k}";
              imports = [ v ];
            });
        description = ''
          Home-manager modules.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
    };
  };
}
