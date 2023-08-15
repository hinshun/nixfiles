{ inputs, parts, ... }: {
  flake.nixosConfigurations.framework = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      parts.nixos.hosts.framework
      inputs.home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.users.hinshun = parts.home.profiles.hinshun;
        home-manager.extraSpecialArgs = {
          firefox = import ../../home/programs/firefox.nix;
          git = import ../../home/programs/git.nix;
        };
      }
    ];
  };
}
