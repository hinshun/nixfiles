{ inputs, ... }:
let
  nix-snapshotter = inputs.nix-snapshotter.overlays.default;

in {
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        nix-snapshotter
      ];
    };
  };
}
