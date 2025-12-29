{ lib, nixosConfigurations, ... }:

with lib;

let
  # nixos-anywhere provisioning options
  nixosAnywhereType = types.submodule {
    options = {
      enable = mkEnableOption "NixOS provisioning via nixos-anywhere" // { default = true; };

      config = mkOption {
        type = types.raw;
        default = nixosConfigurations.minimal;
        description = "NixOS configuration (e.g., nixosConfigurations.minimal)";
      };

      sshUser = mkOption {
        type = types.str;
        default = "root";
        description = "SSH user for nixos-anywhere";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Extra arguments to pass to nixos-anywhere";
      };

      agenix = {
        enable = mkEnableOption "agenix key provisioning" // { default = true; };

        keySource = mkOption {
          type = types.str;
          default = "/run/agenix/infra-age-key";
          description = "Source path of the age key on the local machine";
        };

        keyDestination = mkOption {
          type = types.str;
          default = "/var/lib/agenix/key.txt";
          description = "Destination path for the age key on the remote machine";
        };
      };
    };
  };

  # Colmena options - modules is a NixOS module that can include deployment options
  # Since makeHive applies deploymentOptions to each node, deployment.* can be set in the module
  colmenaType = types.submodule {
    options = {
      enable = mkEnableOption "Colmena deployment for this instance";

      module = mkOption {
        type = types.raw;
        default = null;
        description = ''
          NixOS module for colmena deployment. Can include deployment options directly:

          colmena.module = { ... }: {
            imports = [ ./path/to/configuration.nix ];
            deployment.tags = [ "web" ];
            deployment.targetUser = "root";
          };
        '';
      };
    };
  };

in {
  options.infra._types = {
    nixosAnywhere = mkOption {
      type = types.raw;
      default = nixosAnywhereType;
      internal = true;
      description = "Shared nixos-anywhere option type";
    };

    colmena = mkOption {
      type = types.raw;
      default = colmenaType;
      internal = true;
      description = "Shared colmena option type";
    };
  };
}
