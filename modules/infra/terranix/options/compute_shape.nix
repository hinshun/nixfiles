{ lib, ... }:

with lib;

let
  # Standardized instance families across all clouds
  instanceFamilies = [
    "general"        # Standard balanced instances
    "cpu-optimized"  # High CPU performance (dedicated vCPU)
    "mem-optimized"  # High memory ratio
    "disk-optimized" # High storage capacity
    "cost-optimized" # Budget-friendly (Arm, shared, burstable)
  ];

  # Compute shape type definition
  computeShapeType = types.submodule {
    options = {
      cloud = mkOption {
        type = types.enum [ "hcloud" "aws" "gcp" "azure" ];
        description = "Cloud provider identifier";
      };

      name = mkOption {
        type = types.str;
        description = "Human-readable name for the shape";
      };

      api_name = mkOption {
        type = types.str;
        description = "Provider's API identifier (e.g., 'cpx11', 't3.micro')";
      };

      family = mkOption {
        type = types.enum instanceFamilies;
        description = "Standardized instance family";
      };

      cores = mkOption {
        type = types.int;
        description = "Number of CPU cores";
      };

      mem = mkOption {
        type = types.int;
        description = "Memory in GB";
      };

      disk = mkOption {
        type = types.int;
        description = "Local disk size in GB";
      };

      on_demand_hourly = mkOption {
        type = types.float;
        description = "On-demand hourly price";
      };

      spot_hourly = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Spot/preemptible hourly price (null if unavailable)";
      };
    };
  };

in {
  options.compute = {
    shapes = mkOption {
      type = types.attrsOf computeShapeType;
      default = {};
      description = "All available compute shapes across cloud providers";
    };

    # Export the type for use in other modules
    _types.shape = mkOption {
      type = types.raw;
      default = computeShapeType;
      internal = true;
      description = "Compute shape type for use in other modules";
    };
  };
}
