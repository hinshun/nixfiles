#!/usr/bin/env python3
"""
Generate normalized compute shape data from Hetzner Cloud.

Usage:
    python generate-hcloud-shapes.py > ../modules/infra/terranix/options/data/hcloud-shapes.json
    python generate-hcloud-shapes.py -o ../modules/infra/terranix/options/data/hcloud-shapes.json
"""

import json
import subprocess
import sys
import argparse
import re


def run_hcloud_command():
    """Execute hcloud server-type list and return parsed JSON."""
    result = subprocess.run(
        ["hcloud", "server-type", "list", "-o", "json"],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)


def extract_family(name):
    """Map hcloud server type to standardized family name.

    Standardized families (same across all clouds):
        - general: Standard balanced instances
        - cpu-optimized: High CPU performance (dedicated vCPU)
        - mem-optimized: High memory ratio
        - disk-optimized: High storage capacity
        - cost-optimized: Budget-friendly options (Arm, shared, etc.)

    Hetzner mappings:
        cx, cpx -> general (shared vCPU, x86)
        cax -> cost-optimized (Arm64, cheaper)
        ccx -> cpu-optimized (dedicated vCPU)
    """
    # Extract the prefix (letters before numbers)
    match = re.match(r"^([a-z]+)", name)
    prefix = match.group(1) if match else name

    family_map = {
        "cx": "general",
        "cpx": "general",
        "cax": "cost-optimized",
        "ccx": "cpu-optimized",
    }

    return family_map.get(prefix, "general")


def transform_server_type(server_type):
    """Transform hcloud server type to normalized compute shape."""
    name = server_type["name"]

    # Find minimum hourly price across all locations
    prices = server_type.get("prices", [])
    if prices:
        min_hourly = min(float(p["price_hourly"]["gross"]) for p in prices)
    else:
        min_hourly = 0.0

    return {
        "cloud": "hcloud",
        "name": server_type.get("description", name),
        "api_name": name,
        "family": extract_family(name),
        "cores": server_type["cores"],
        "mem": int(server_type["memory"]),
        "disk": server_type["disk"],
        "on_demand_hourly": min_hourly,
        "spot_hourly": None,  # hcloud doesn't have spot instances
    }


def main():
    parser = argparse.ArgumentParser(
        description="Generate normalized compute shape data from Hetzner Cloud"
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Output file path (default: stdout)",
        default=None,
    )
    args = parser.parse_args()

    # Fetch and transform data
    server_types = run_hcloud_command()

    # Filter out deprecated server types
    active_types = [st for st in server_types if not st.get("deprecated", False)]

    # Transform to normalized format
    shapes = [transform_server_type(st) for st in active_types]

    # Create output structure keyed by api_name
    output = {shape["api_name"]: shape for shape in shapes}

    # Output
    json_output = json.dumps(output, indent=2, sort_keys=True)

    if args.output:
        with open(args.output, "w") as f:
            f.write(json_output)
            f.write("\n")
        print(f"Wrote {len(output)} shapes to {args.output}", file=sys.stderr)
    else:
        print(json_output)


if __name__ == "__main__":
    main()
