{ config, lib, pkgs, inputs, nixosModules, secrets, ... }:

let
  cfg = config.infra.zerofs;
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

    services.zerofs = {
      enable = true;
      environmentFile = config.age.secrets.zerofs-s3-env.path;
      settings = {
        cache.dir = "/var/cache/zerofs";
        cache.disk_size_gb = 10.0;
        storage.url = "s3://hinshun-infra-zerofs/${cfg.prefix}";
        storage.encryption_password = "test-password";
        servers.ninep.unix_socket = "/run/zerofs/zerofs.9p.sock";
        aws = {
          access_key_id = "\${AWS_ACCESS_KEY_ID}";
          secret_access_key = "\${AWS_SECRET_ACCESS_KEY}";
          region = "us-east-1";
        };
      };
    };

    systemd.services.zerofs-9p-mount = {
      description = "Mount zerofs via 9P";
      after = [ "zerofs.service" ];
      requires = [ "zerofs.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ util-linux coreutils ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStart = pkgs.writeShellScript "zerofs-9p-mount" ''
          set -euo pipefail
          until [ -S /run/zerofs/zerofs.9p.sock ]; do sleep 0.1; done
          sleep 1
          mkdir -p ${zfsMountpoint}
          mount -t 9p -o trans=unix,version=9p2000.L,cache=mmap /run/zerofs/zerofs.9p.sock ${zfsMountpoint}
        '';

        ExecStop = pkgs.writeShellScript "zerofs-9p-umount" ''
          umount ${zfsMountpoint} || true
        '';
      };
    };
  };
}
