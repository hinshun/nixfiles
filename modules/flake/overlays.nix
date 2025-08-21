{ inputs, ... }:
{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = with inputs; [
        agenix.overlays.default
        nix.overlays.default
        nix-snapshotter.overlays.default
      ];
      config.allowUnfree = true;
    };
  };
}
