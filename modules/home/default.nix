{ lib, inputs, ... }:
let
  inputModules = {
    nix-snapshotter = inputs.nix-snapshotter.homeModules.default;
    noctalia = inputs.noctalia.homeModules.default;
  };

in {
  flake.homeModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
