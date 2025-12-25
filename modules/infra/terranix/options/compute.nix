{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.compute;

  # Standardized instance families
  instanceFamilies = [
    "general"
    "cpu-optimized"
    "mem-optimized"
    "disk-optimized"
    "cost-optimized"
  ];

  # Requirements submodule
  requirementsType = types.submodule {
    options = {
      cores = mkOption {
        type = types.int;
        default = 1;
        description = "Minimum CPU cores";
      };

      mem = mkOption {
        type = types.int;
        default = 1;
        description = "Minimum memory in GB";
      };

      disk = mkOption {
        type = types.int;
        default = 20;
        description = "Minimum disk size in GB";
      };

      family = mkOption {
        type = types.enum ([ "any" ] ++ instanceFamilies);
        default = "any";
        description = "Instance family filter (any = no filtering)";
      };
    };
  };

  # NixOS provisioning submodule
  nixosType = types.submodule {
    options = {
      enable = mkEnableOption "NixOS provisioning via nixos-anywhere";

      baseConfig  = mkOption {
        type = types.raw;
        default = null;
        description = "NixOS configuration (e.g., nixosConfigurations.minecraft)";
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
    };
  };

  # Instance submodule
  instanceType = types.submodule ({ name, ... }: {
    options = {
      enable = mkEnableOption "this compute instance" // { default = true; };

      name = mkOption {
        type = types.str;
        default = name;
        description = "Instance name/hostname";
      };

      cloud = mkOption {
        type = types.nullOr (types.enum [ "hcloud" "aws" "gcp" "azure" ]);
        default = null;
        description = "Force specific cloud provider (null = auto-select cheapest)";
      };

      requirements = mkOption {
        type = requirementsType;
        default = {};
        description = "Resource requirements for shape selection";
      };

      nixos = mkOption {
        type = nixosType;
        default = {};
        description = "NixOS provisioning configuration";
      };

      # Provider-specific overrides
      hcloud = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Hetzner-specific configuration overrides";
      };

      aws = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "AWS-specific configuration overrides";
      };
    };
  });

  # Shape picker logic
  findCheapestShape = { requirements, cloud ? null }:
    let
      allShapes = attrValues cfg.shapes;

      # Filter by cloud if specified
      cloudFiltered = if cloud != null
        then filter (s: s.cloud == cloud) allShapes
        else allShapes;

      # Filter by minimum requirements
      meetsRequirements = shape:
        shape.cores >= requirements.cores &&
        shape.mem >= requirements.mem &&
        shape.disk >= requirements.disk &&
        (requirements.family == "any" || shape.family == requirements.family);

      requirementFiltered = filter meetsRequirements cloudFiltered;

      # Sort by on_demand_hourly cost
      sorted = sort (a: b: a.on_demand_hourly < b.on_demand_hourly) requirementFiltered;

    in if sorted == [] then null else head sorted;

  # Process each instance
  resolveInstance = name: instance:
    let
      result = findCheapestShape {
        requirements = instance.requirements;
        cloud = instance.cloud;
      };
    in instance // {
      _resolved = {
        shape = result;
        hourly_cost = if result != null then result.on_demand_hourly else null;
      };
    };

in {
  options.compute.instances = mkOption {
    type = types.attrsOf instanceType;
    default = {};
    description = "High-level compute instances with automatic shape selection";
  };

  config = let
    # Resolve all instances
    resolvedInstances = mapAttrs resolveInstance cfg.instances;

    # Filter to enabled instances with resolved shapes
    enabledInstances = filterAttrs
      (_: inst: inst.enable && inst._resolved.shape != null)
      resolvedInstances;

    # Group by cloud provider
    hcloudInstances = filterAttrs
      (_: inst: inst._resolved.shape.cloud == "hcloud")
      enabledInstances;

    # Check for unresolved instances
    unresolvedInstances = filterAttrs
      (_: inst: inst.enable && inst._resolved.shape == null)
      resolvedInstances;

    allResolved = unresolvedInstances == {};

    # Instances with nixos provisioning enabled
    nixosInstances = filterAttrs
      (_: inst: inst.nixos.enable)
      enabledInstances;

    # Helper to get server IP reference based on cloud
    getServerIpRef = cloud: name:
      if cloud == "hcloud" then "\${hcloud_server.${name}.ipv4_address}"
      else if cloud == "aws" then "\${aws_instance.${name}.public_ip}"
      else throw "Unsupported cloud provider for nixos-anywhere: ${cloud}";

    # Helper to get server dependency based on cloud
    getServerDep = cloud: name:
      if cloud == "hcloud" then "hcloud_server.${name}"
      else if cloud == "aws" then "aws_instance.${name}"
      else throw "Unsupported cloud provider for nixos-anywhere: ${cloud}";

  in mkAssert allResolved
    "No shape found matching requirements for: ${concatStringsSep ", " (attrNames unresolvedInstances)}"
  {
    # Generate hcloud servers from compute.instances
    hcloud.servers = mapAttrs (name: inst: {
      name = inst.name;
      server_type = inst._resolved.shape.api_name;
    } // inst.hcloud) hcloudInstances;

    # Generate nixos-anywhere provisioners
    resource.null_resource = mapAttrs (name: inst: {
      depends_on = [ (getServerDep inst._resolved.shape.cloud name) ];

      triggers = {
        server_id = "\${${getServerDep inst._resolved.shape.cloud name}.id}";
      };

      provisioner.local-exec = {
        command = let
          cfg = inst.nixos.baseConfig;
          diskoScript = cfg.config.system.build.diskoScript;
          toplevel = cfg.config.system.build.toplevel;
        in concatStringsSep " " ([
          "${pkgs.nixos-anywhere}/bin/nixos-anywhere"
          "--store-paths ${diskoScript} ${toplevel}"
        ] ++ inst.nixos.extraArgs ++ [
          "${inst.nixos.sshUser}@${getServerIpRef inst._resolved.shape.cloud name}"
        ]);
      };
    }) nixosInstances;

    # Generate outputs for instance IPs
    output = mapAttrs (name: inst: {
      value = getServerIpRef inst._resolved.shape.cloud name;
      description = "Public IP address of ${name}";
    }) enabledInstances;
  };
}
