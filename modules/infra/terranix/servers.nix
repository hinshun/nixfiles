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
      module = { nixosModules, ... }: {
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
