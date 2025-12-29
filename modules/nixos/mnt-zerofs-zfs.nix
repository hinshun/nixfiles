{ config, lib, pkgs, inputs, nixosModules, secrets, ... }:

let
  cfg = config.infra.zerofs;

  nbdDevice = "/dev/nbd0";
  nbdExportName = "zerofs-data";
  nbdDeviceSize = "100G";

  zpoolName = "zerofs";
  zfsDataset = "${zpoolName}/data";
  zfsMountpoint = "/mnt/zerofs";

in {
  imports = [
    nixosModules.agenix
    inputs.zerofs.nixosModules.zerofs
  ];

  options.infra.zerofs.prefix = lib.mkOption {
    type = lib.types.str;
    description = "S3 prefix for zerofs storage";
  };

  config = {
    age.identityPaths = [ "/var/lib/agenix/key.txt" ];
    age.secrets.zerofs-s3-env = {
      file = secrets.ageSecrets.zerofs-s3-env;
      mode = "0400";
    };

    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
    boot.kernelModules = [ "nbd" ];
    networking.hostId = "8425e349";

    environment.systemPackages = with pkgs; [ nbd zfs ];

    services.zerofs = {
      enable = true;
      environmentFile = config.age.secrets.zerofs-s3-env.path;
      settings = {
        cache.dir = "/var/cache/zerofs";
        cache.disk_size_gb = 10.0;
        storage.url = "s3://hinshun-infra-zerofs/${cfg.prefix}";
        storage.encryption_password = "test-password";
        servers.ninep.unix_socket = "/run/zerofs/zerofs.9p.sock";
        servers.nbd.addresses = [ "127.0.0.1:10809" ];
        aws = {
          access_key_id = "\${AWS_ACCESS_KEY_ID}";
          secret_access_key = "\${AWS_SECRET_ACCESS_KEY}";
          region = "us-east-1";
        };
      };
    };

    systemd.services.zerofs-zfs-setup = {
      description = "Setup zerofs NBD device and ZFS pool";
      after = [ "zerofs.service" "systemd-modules-load.service" ];
      requires = [ "zerofs.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ util-linux nbd coreutils zfs netcat ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStart = pkgs.writeShellScript "zerofs-zfs-setup" ''
          set -euo pipefail

          until [ -S /run/zerofs/zerofs.9p.sock ]; do sleep 0.1; done
          until nc -z 127.0.0.1 10809 2>/dev/null; do sleep 0.1; done
          sleep 1

          # Create NBD device file via 9P if needed
          TMPDIR=$(mktemp -d)
          mount -t 9p -o trans=unix,version=9p2000.L /run/zerofs/zerofs.9p.sock "$TMPDIR"
          [ ! -f "$TMPDIR/.nbd/${nbdExportName}" ] && truncate -s ${nbdDeviceSize} "$TMPDIR/.nbd/${nbdExportName}"
          umount "$TMPDIR" && rmdir "$TMPDIR"

          # Connect NBD
          nbd-client -d ${nbdDevice} 2>/dev/null || true
          nbd-client 127.0.0.1 10809 ${nbdDevice} -N ${nbdExportName} -persist -timeout 600

          # Setup ZFS pool
          if ! zpool list ${zpoolName} &>/dev/null; then
            if ! zpool import -N ${zpoolName} 2>/dev/null; then
              zpool create -f -o ashift=12 ${zpoolName} ${nbdDevice}
              zfs create -o mountpoint=${zfsMountpoint} \
                         -o compression=lz4 -o atime=off -o recordsize=128K \
                         -o xattr=sa -o logbias=throughput \
                         ${zfsDataset}
            fi
          fi

          # Apply tuning and mount
          zfs set compression=lz4 logbias=throughput xattr=sa ${zfsDataset} 2>/dev/null || true
          zfs mount ${zfsDataset} 2>/dev/null || true
        '';

        ExecStop = pkgs.writeShellScript "zerofs-zfs-teardown" ''
          zfs unmount ${zfsDataset} || true
          zpool export ${zpoolName} || true
          nbd-client -d ${nbdDevice} || true
        '';
      };
    };
  };
}
