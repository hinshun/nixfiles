{ lib, inputs, ... }:
let
  inputModules = {
    inherit (inputs.home-manager.nixosModules)
      home-manager
    ;
    inherit (inputs.nix-snapshotter.nixosModules)
      nix-snapshotter
    ;
  };

in {
  flake.nixosModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
