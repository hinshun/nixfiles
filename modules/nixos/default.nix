{ inputs, ... }:
let
  inputModules = {
    inherit (inputs.home-manager.nixosModules) home-manager;
    nix-snapshotter = inputs.nix-snapshotter.nixosModules.default;
  };

in {
  flake.nixosModules = inputModules // {
    eraseDarlings = ./eraseDarlings.nix;
    erofs = ./erofs.nix;
    modernNix = ./modernNix.nix;
    nixbuild = ./nixbuild.nix;
    vmVariant = ./vmVariant.nix;
  };
}
