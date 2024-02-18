{ lib, inputs, ... }:
let
  inputModules = {
    inherit (inputs.home-manager.nixosModules)
      home-manager
    ;
  };

in {
  flake.nixosModules = lib.mkMerge [
    (lib.readModules ./.)
    inputModules
  ];
}
