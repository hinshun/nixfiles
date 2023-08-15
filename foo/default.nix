{ inputs, parts, ... }: {
  flake.nixosConfigurations.framework = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      parts.foo.framework
      inputs.home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.users.hinshun = parts.home.profiles.hinshun;
      }
    ];
  };
}
