{ inputs, ... }:
let
  nix-snapshotter = inputs.nix-snapshotter.overlays.default;

in {
  perSystem = { pkgs, ... }: {
    _module.args.pkgs' = pkgs.appendOverlays [
      nix-snapshotter
    ];
  };
}
