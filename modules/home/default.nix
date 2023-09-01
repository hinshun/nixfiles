{ lib, inputs, ... }:
let
  inputModules = with inputs; {
    nix-snapshotter = nix-snapshotter.homeModules.default;
  };

in {
  flake.homeModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
