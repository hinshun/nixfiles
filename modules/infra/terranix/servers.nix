{ ... }:
{
  compute.instances.minecraft = {
    name = "minecraft";
    requirements = {
      cores = 8;
      family = "cpu-optimized";
    };

    colmena = {
      enable = true;
      modules = { nixosModules, ... }: {
        imports = [ nixosModules.cloud-minimal ];
        services.minecraft-server = {
          enable = true;
          eula = true;
        };
        deployment.tags = [ "gaming" ];
      };
    };
  };
}
