{ self, inputs, ... }:
{
  _module.args.profiles = {
    hinshun = ./hinshun.nix;
  };

  perSystem = { pkgs, ... }:
    let
      hinshun = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hinshun.nix
        ];
        extraSpecialArgs = { inherit (self) homeModules; };
      };

    in {
      # legacyPackages.homeConfigurations = { inherit hinshun; };
      packages.hinshun = hinshun.activationPackage;
    };
}
