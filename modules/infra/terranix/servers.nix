{ ... }:
{
  compute.instances.minecraft = {
    # enable = false;
    name = "minecraft";
    requirements = {
      cores = 8;
      family = "cpu-optimized";
    };

    colmena = {
      enable = true;
      module = { pkgs, nixosModules, ... }: {
        imports = with nixosModules; [
          cloud-minimal
          mnt-zerofs
        ];

        environment.systemPackages = with pkgs; [
          fio
          python3
          uv
        ];

        infra.zerofs.prefix = "minecraft/raspberry-flavoured";

        services.minecraft-server = {
          enable = true;
          eula = true;
          dataDir = "/mnt/zerofs";
          openFirewall = true;
          package = pkgs.minecraft-raspberry-flavoured;
          jvmOpts = "-Xmx6G -Xms6G"
            + "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 "
            + "-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC "
            + "-XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 "
            + "-XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M "
            + "-XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 "
            + "-XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 "
            + "-XX:G1MixedGCLiveThresholdPercent=90 "
            + "-XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 "
            + "-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 "
            + "-Dusing.aikars.flags=https://mcflags.emc.gs "
            + "-Daikars.new.flags=true";
        };

        systemd.services.minecraft-server = {
          after = [ "mnt-zerofs.mount" ];
          wants = [ "mnt-zerofs.mount" ];
        };

        deployment.tags = [ "gaming" ];
      };
    };
  };
}
