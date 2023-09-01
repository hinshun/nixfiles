{ lib, inputs, ... }:
let
  inputModules = with inputs; {
    inherit (home-manager.nixosModules) home-manager;
    nix-snapshotter = nix-snapshotter.nixosModules.default;
  };

in {
  flake.nixosModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
