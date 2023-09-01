{ lib, inputs, ... }:
let
  inputModules = {
    inherit (inputs.nix-snapshotter.homeModules)
      nix-snapshotter-rootless
    ;
  };

in {
  flake.homeModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
