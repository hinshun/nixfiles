{ inputs, ... }:
let
  inputModules = {
    inherit (inputs.home-manager.nixosModules) home-manager;
    nix-snapshotter = inputs.nix-snapshotter.nixosModules.default;
  };

in {
  flake.nixosModules = inputModules // {
    vmVariant = ./vmVariant.nix;
  };
}
