{ config, lib, ... }:

with lib;

let
  cfg = config.hcloud;

  # Import generated shape data
  shapesData = builtins.fromJSON (builtins.readFile ./data/hcloud-shapes.json);

  # Server submodule type
  serverType = types.submodule ({ name, ... }: {
    options = {
      enable = mkEnableOption "this hcloud server" // { default = true; };

      name = mkOption {
        type = types.str;
        default = name;
        description = "Server hostname";
      };

      image = mkOption {
        type = types.str;
        default = "debian-12";
        description = "OS image to use";
      };

      server_type = mkOption {
        type = types.str;
        description = "Hetzner server type (e.g., cpx11, cx22)";
      };

      datacenter = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Specific datacenter (e.g., nbg1-dc3). If null, uses location.";
      };

      location = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Location (e.g., nbg1, ash). Used if datacenter is null.";
      };

      ssh_keys = mkOption {
        type = types.listOf types.str;
        default = [ "\${hcloud_ssh_key.framework.id}" ];
        description = "SSH key references for the server";
      };

      public_net = mkOption {
        type = types.submodule {
          options = {
            ipv4_enabled = mkOption {
              type = types.bool;
              default = true;
            };
            ipv6_enabled = mkOption {
              type = types.bool;
              default = true;
            };
          };
        };
        default = {};
        description = "Public network configuration";
      };

      extra = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Additional terraform attributes to pass through";
      };
    };
  });

in {
  options.hcloud = {
    compute_shapes = mkOption {
      type = types.attrsOf config.compute._types.shape;
      default = {};
      readOnly = true;
      description = "Available Hetzner Cloud compute shapes";
    };

    servers = mkOption {
      type = types.attrsOf serverType;
      default = {};
      description = "Hetzner Cloud servers to provision";
    };
  };

  config = {
    # Populate hcloud.compute_shapes from imported JSON
    hcloud.compute_shapes = shapesData;

    # Also register shapes in the global compute.shapes namespace
    compute.shapes = mapAttrs' (name: shape:
      nameValuePair "hcloud-${name}" shape
    ) shapesData;

    # Generate terraform resources for each enabled server
    resource.hcloud_server = mapAttrs (name: serverCfg:
      mkIf serverCfg.enable ({
        name = serverCfg.name;
        image = serverCfg.image;
        server_type = serverCfg.server_type;
        ssh_keys = serverCfg.ssh_keys;
        public_net = serverCfg.public_net;
      } // (optionalAttrs (serverCfg.datacenter != null) {
        datacenter = serverCfg.datacenter;
      }) // (optionalAttrs (serverCfg.datacenter == null && serverCfg.location != null) {
        location = serverCfg.location;
      }) // serverCfg.extra)
    ) (filterAttrs (_: s: s.enable) cfg.servers);
  };
}
