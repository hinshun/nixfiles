{ lib, inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = with inputs; [
        agenix.overlays.default
        nix-snapshotter.overlays.default
        mcman.overlays.default
        zerofs.overlays.default
      ] ++ [
        (self: super:
          let pkgsByName = (builtins.readDir ../pkgs);
          in lib.mapAttrs (name: _: pkgs.callPackage (../pkgs + "/${name}") {}) pkgsByName
        )
      ];
      config.allowUnfree = true;
    };

    packages.raspberry = pkgs.minecraft-raspberry-flavoured;
  };
}
