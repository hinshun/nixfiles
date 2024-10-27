{ lib, inputs, ... }:
let
  inputModules = {
    inherit (inputs.home-manager.nixosModules)
      home-manager
    ;
    inherit (inputs.nix-snapshotter.nixosModules)
      nix-snapshotter
      containerd
      buildkitd
    ;
    agenix = inputs.agenix.nixosModules.default;
  };

in {
  flake.nixosModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
