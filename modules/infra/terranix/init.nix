{ config, lib, ... }:

with lib;

let
  cfg = config.infra;
in {
  config = {
    terraform.backend.s3 = {
      bucket = "hinshun-infra-terraform";
      key = "terraform.tfstate";
      region = "us-east-1";
      use_lockfile = true;
    };

    # Hetzner Cloud provider
    provider.hcloud = {
      token = ''''${trimspace(file("/run/agenix/hetzner-cloud"))}'';
    };

    # Default SSH key
    infra.sshKeys.framework = {
      name = "framework";
      publicKeyFile = "~/.ssh/id_ed25519.pub";
    };

    # Generate hcloud_ssh_key resources from infra.sshKeys
    resource.hcloud_ssh_key = mapAttrs (name: keyCfg: {
      name = keyCfg.name;
      public_key = ''''${file("${keyCfg.publicKeyFile}")}'';
    }) cfg.sshKeys;
  };
}
