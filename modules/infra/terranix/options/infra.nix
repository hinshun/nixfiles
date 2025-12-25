{ lib, ... }:

with lib;

{
  options.infra = {
    sshKeys = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the SSH key";
          };
          publicKeyFile = mkOption {
            type = types.str;
            description = "Path to the public key file";
          };
        };
      });
      default = {};
      description = "SSH keys to provision across cloud providers";
    };

    _colmenaInstances = mkOption {
      type = types.attrsOf types.raw;
      default = {};
      internal = true;
      description = "Instances with colmena.enable = true, used for hive generation";
    };
  };
}
