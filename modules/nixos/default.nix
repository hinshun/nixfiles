{ lib, inputs, ... }:
let
  inputModules = {
    agenix = inputs.agenix.nixosModules.default;
    inherit (inputs.disko.nixosModules) disko;
    inherit (inputs.home-manager.nixosModules) home-manager;
    inherit (inputs.nix-snapshotter.nixosModules) nix-snapshotter;
    inherit (inputs.nixos-hardware.nixosModules) framework-11th-gen-intel;
    inherit (inputs.zerofs.nixosModules) zerofs;
  };

in {
  flake.nixosModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
