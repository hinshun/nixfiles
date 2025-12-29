{ config, lib, pkgs, inputs, nixosModules, secrets, ... }:

let
  cfg = config.infra.zerofs;

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
        cache = {
          dir = "/var/cache/zerofs";
          disk_size_gb = 10.0;
        };
        storage = {
          url = "s3://hinshun-infra-zerofs/${cfg.prefix}";
          encryption_password = "test-password";
        };
        servers.ninep.unix_socket = "/run/zerofs/zerofs.9p.sock";
        aws = {
          access_key_id = "\${AWS_ACCESS_KEY_ID}";
          secret_access_key = "\${AWS_SECRET_ACCESS_KEY}";
          region = "us-east-1";
        };
      };
    };

    systemd.services.mnt-zerofs-wait = {
      description = "Wait for zerofs 9p socket";
      after = [ "zerofs.service" ];
      requires = [ "zerofs.service" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'until [ -S /run/zerofs/zerofs.9p.sock ]; do sleep 0.1; done; sleep 2'";
        RemainAfterExit = true;
      };
    };

    systemd.mounts = [{
      what = "/run/zerofs/zerofs.9p.sock";
      where = "/mnt/zerofs";
      type = "9p";
      options = "trans=unix,version=9p2000.L,cache=mmap,access=user";
      after = [ "mnt-zerofs-wait.service" ];
      requires = [ "mnt-zerofs-wait.service" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.DefaultDependencies = false;
    }];
  };
}
