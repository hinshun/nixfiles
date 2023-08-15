{ inputs, parts, ... }: {
  perSystem = { pkgs, ... }:
    let
      hinshun = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          parts.home.profiles.hinshun
        ];
        extraSpecialArgs = { inherit parts; };
      };

    in {
      legacyPackages.homeConfigurations = { inherit hinshun; };
      packages.hinshun = hinshun.activationPackage;
    };
}
