{ inputs, ... }:
{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = with inputs; [
        agenix.overlays.default
        nix-snapshotter.overlays.default
        (self: super: {
          hlb = self.callPackage ../../packages/hlb {};
        })
      ];
      config.allowUnfree = true;
    };
  };
}
