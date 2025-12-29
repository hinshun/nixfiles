#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "boto3",
# ]
# ///
"""
S3 Bucket Cost Estimator

Estimates the monthly cost of an S3 bucket based on storage size and storage classes.
Compares with block storage (disk) costs from various cloud providers.

Usage: AWS_PROFILE=homelab uv run s3_cost_estimator.py <bucket-name> [--region us-east-1]
"""

import argparse
import sys
from collections import defaultdict

import boto3
from botocore.exceptions import ClientError, NoCredentialsError, ProfileNotFound


# =============================================================================
# Block Storage (Disk) Pricing - per GB/month (USD)
# Prices as of late 2024 - check provider pricing pages for current rates
# =============================================================================

DISK_PRICING = {
    # AWS EBS - https://aws.amazon.com/ebs/pricing/
    "AWS EBS": {
        "gp3 (General Purpose SSD)": 0.08,
        "gp2 (General Purpose SSD)": 0.10,
        "io1 (Provisioned IOPS SSD)": 0.125,
        "io2 (Provisioned IOPS SSD)": 0.125,
        "st1 (Throughput HDD)": 0.045,
        "sc1 (Cold HDD)": 0.015,
    },
    # GCP Persistent Disk - https://cloud.google.com/compute/disks-image-pricing
    "GCP Persistent Disk": {
        "Standard (HDD)": 0.04,
        "Balanced (SSD)": 0.10,
        "SSD": 0.17,
        "Extreme (SSD)": 0.125,
    },
    # Azure Managed Disks - https://azure.microsoft.com/en-us/pricing/details/managed-disks/
    # Note: Azure uses tiered pricing, these are approximate $/GB for mid-size disks
    "Azure Managed Disks": {
        "Standard HDD (S20 512GB)": 0.038,
        "Standard SSD (E20 512GB)": 0.076,
        "Premium SSD (P20 512GB)": 0.152,
        "Ultra Disk": 0.12,  # Base storage, IOPS/throughput charged separately
    },
    # Hetzner Cloud - https://docs.hetzner.com/cloud/volumes/overview/
    "Hetzner Cloud": {
        "Volume (NVMe, triple-replicated)": 0.048,  # €0.044 ≈ $0.048
    },
    # DigitalOcean - https://www.digitalocean.com/pricing/volumes
    "DigitalOcean": {
        "Block Storage (SSD)": 0.10,
    },
    # Vultr - https://www.vultr.com/products/block-storage/
    "Vultr": {
        "Block Storage (NVMe)": 0.10,
        "Block Storage (HDD)": 0.01,
    },
    # Linode/Akamai - https://www.linode.com/pricing/
    "Linode": {
        "Block Storage (NVMe)": 0.10,
    },
    # OVHcloud - https://www.ovhcloud.com/en/public-cloud/prices/
    "OVHcloud": {
        "Block Storage Classic": 0.04,
        "Block Storage High Speed": 0.08,
    },
}

# S3 pricing per GB/month (US East - N. Virginia as default)
# Prices as of 2024 - check AWS pricing page for current rates
S3_PRICING = {
    "us-east-1": {
        "STANDARD": 0.023,
        "INTELLIGENT_TIERING": 0.023,  # Frequent access tier
        "STANDARD_IA": 0.0125,
        "ONEZONE_IA": 0.01,
        "GLACIER_INSTANT_RETRIEVAL": 0.004,
        "GLACIER": 0.0036,
        "GLACIER_FLEXIBLE_RETRIEVAL": 0.0036,
        "DEEP_ARCHIVE": 0.00099,
        "REDUCED_REDUNDANCY": 0.024,
        "OUTPOSTS": 0.0,  # Priced differently
        "GLACIER_IR": 0.004,  # Alias
    },
    "us-west-2": {
        "STANDARD": 0.023,
        "INTELLIGENT_TIERING": 0.023,
        "STANDARD_IA": 0.0125,
        "ONEZONE_IA": 0.01,
        "GLACIER_INSTANT_RETRIEVAL": 0.004,
        "GLACIER": 0.0036,
        "GLACIER_FLEXIBLE_RETRIEVAL": 0.0036,
        "DEEP_ARCHIVE": 0.00099,
        "REDUCED_REDUNDANCY": 0.024,
    },
    "eu-west-1": {
        "STANDARD": 0.024,
        "INTELLIGENT_TIERING": 0.024,
        "STANDARD_IA": 0.0131,
        "ONEZONE_IA": 0.0105,
        "GLACIER_INSTANT_RETRIEVAL": 0.005,
        "GLACIER": 0.0045,
        "GLACIER_FLEXIBLE_RETRIEVAL": 0.0045,
        "DEEP_ARCHIVE": 0.0018,
        "REDUCED_REDUNDANCY": 0.024,
    },
}

# Default pricing for regions not explicitly listed
DEFAULT_PRICING = S3_PRICING["us-east-1"]


def get_bucket_region(s3_client, bucket_name: str) -> str:
    """Get the region where the bucket is located."""
    try:
        response = s3_client.get_bucket_location(Bucket=bucket_name)
        # None means us-east-1
        location = response.get("LocationConstraint")
        return location if location else "us-east-1"
    except ClientError as e:
        print(f"Warning: Could not determine bucket region: {e}")
        return "us-east-1"


def get_storage_metrics(s3_client, bucket_name: str) -> dict:
    """
    Calculate storage metrics by listing all objects in the bucket.
    Returns dict with storage class breakdowns.
    """
    storage_by_class = defaultdict(lambda: {"size_bytes": 0, "object_count": 0})
    total_objects = 0
    total_size = 0

    paginator = s3_client.get_paginator("list_objects_v2")

    try:
        for page in paginator.paginate(Bucket=bucket_name):
            if "Contents" not in page:
                continue

            for obj in page["Contents"]:
                size = obj.get("Size", 0)
                storage_class = obj.get("StorageClass", "STANDARD")

                storage_by_class[storage_class]["size_bytes"] += size
                storage_by_class[storage_class]["object_count"] += 1
                total_objects += 1
                total_size += size

    except ClientError as e:
        print(f"Error listing objects: {e}")
        sys.exit(1)

    return {
        "by_class": dict(storage_by_class),
        "total_objects": total_objects,
        "total_size_bytes": total_size,
    }


def bytes_to_gb(size_bytes: int) -> float:
    """Convert bytes to gigabytes."""
    return size_bytes / (1024**3)


def format_size(size_bytes: int) -> str:
    """Format bytes to human-readable string."""
    for unit in ["B", "KB", "MB", "GB", "TB", "PB"]:
        if abs(size_bytes) < 1024.0:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.2f} EB"


def calculate_costs(metrics: dict, region: str) -> dict:
    """Calculate estimated monthly costs based on storage metrics."""
    pricing = S3_PRICING.get(region, DEFAULT_PRICING)
    costs_by_class = {}
    total_cost = 0.0

    for storage_class, data in metrics["by_class"].items():
        size_gb = bytes_to_gb(data["size_bytes"])
        price_per_gb = pricing.get(storage_class, pricing.get("STANDARD", 0.023))
        cost = size_gb * price_per_gb

        costs_by_class[storage_class] = {
            "size_bytes": data["size_bytes"],
            "size_gb": size_gb,
            "object_count": data["object_count"],
            "price_per_gb": price_per_gb,
            "monthly_cost": cost,
        }
        total_cost += cost

    return {
        "by_class": costs_by_class,
        "total_monthly_cost": total_cost,
        "total_size_bytes": metrics["total_size_bytes"],
        "total_objects": metrics["total_objects"],
    }


def calculate_disk_comparison(size_gb: float) -> list[dict]:
    """Calculate costs for the same storage size across all disk providers."""
    comparisons = []

    for provider, disk_types in DISK_PRICING.items():
        for disk_type, price_per_gb in disk_types.items():
            monthly_cost = size_gb * price_per_gb
            comparisons.append({
                "provider": provider,
                "disk_type": disk_type,
                "price_per_gb": price_per_gb,
                "monthly_cost": monthly_cost,
            })

    # Sort by monthly cost
    comparisons.sort(key=lambda x: x["monthly_cost"])
    return comparisons


def print_report(bucket_name: str, region: str, costs: dict, show_comparison: bool = True):
    """Print a formatted cost report."""
    print("\n" + "=" * 70)
    print(f"S3 Cost Estimate: {bucket_name}")
    print(f"Region: {region}")
    print("=" * 70)

    print(f"\nTotal Objects: {costs['total_objects']:,}")
    print(f"Total Size: {format_size(costs['total_size_bytes'])}")

    print("\n" + "-" * 70)
    print("Storage Breakdown by Class:")
    print("-" * 70)

    for storage_class, data in sorted(costs["by_class"].items()):
        print(f"\n  {storage_class}:")
        print(f"    Objects:      {data['object_count']:,}")
        print(f"    Size:         {format_size(data['size_bytes'])} ({data['size_gb']:.4f} GB)")
        print(f"    Price/GB:     ${data['price_per_gb']:.4f}")
        print(f"    Monthly Cost: ${data['monthly_cost']:.4f}")

    print("\n" + "=" * 70)
    print(f"ESTIMATED MONTHLY S3 STORAGE COST: ${costs['total_monthly_cost']:.2f}")
    print("=" * 70)

    if show_comparison:
        print_disk_comparison(costs)

    print("\nNote: This estimate includes storage costs only.")
    print("Additional costs may apply for:")
    print("  - API requests (PUT, GET, LIST, etc.)")
    print("  - Data transfer out")
    print("  - S3 Select / Glacier retrieval")
    print("  - Replication, analytics, inventory")


def print_disk_comparison(costs: dict):
    """Print comparison with block storage from various providers."""
    size_gb = bytes_to_gb(costs["total_size_bytes"])
    s3_cost = costs["total_monthly_cost"]

    if size_gb < 0.01:
        print("\n(Skipping disk comparison - storage size too small)")
        return

    comparisons = calculate_disk_comparison(size_gb)

    print("\n" + "=" * 70)
    print(f"DISK STORAGE COMPARISON (for {size_gb:.2f} GB)")
    print("=" * 70)
    print(f"\n{'Provider':<22} {'Disk Type':<30} {'$/GB':>7} {'Monthly':>10}")
    print("-" * 70)

    # Print S3 cost first for reference
    s3_price_per_gb = s3_cost / size_gb if size_gb > 0 else 0
    print(f"{'>> YOUR S3 BUCKET':<22} {'(current)':<30} ${s3_price_per_gb:>5.3f} ${s3_cost:>9.2f}")
    print("-" * 70)

    for item in comparisons:
        diff = item["monthly_cost"] - s3_cost
        diff_pct = (diff / s3_cost * 100) if s3_cost > 0 else 0
        diff_str = f"({diff_pct:+.0f}%)" if abs(diff_pct) >= 1 else ""

        print(
            f"{item['provider']:<22} "
            f"{item['disk_type']:<30} "
            f"${item['price_per_gb']:>5.3f} "
            f"${item['monthly_cost']:>9.2f} {diff_str}"
        )

    print("-" * 70)

    # Summary
    cheapest = comparisons[0]
    most_expensive = comparisons[-1]

    print(f"\nCheapest disk option:    {cheapest['provider']} {cheapest['disk_type']}")
    print(f"                         ${cheapest['monthly_cost']:.2f}/month "
          f"({((cheapest['monthly_cost'] - s3_cost) / s3_cost * 100):+.1f}% vs S3)")

    print(f"\nMost expensive option:   {most_expensive['provider']} {most_expensive['disk_type']}")
    print(f"                         ${most_expensive['monthly_cost']:.2f}/month "
          f"({((most_expensive['monthly_cost'] - s3_cost) / s3_cost * 100):+.1f}% vs S3)")

    # Find break-even point
    print("\n" + "-" * 70)
    print("KEY INSIGHTS:")
    print("-" * 70)
    print("• S3 is typically cheaper for pure storage (no IOPS requirements)")
    print("• Block storage required if you need: filesystem access, databases,")
    print("  low-latency random I/O, or mounting to compute instances")
    print("• S3 has additional request costs; block storage has IOPS limits")
    print("• Hetzner/OVHcloud offer best value for budget-conscious workloads")


def main():
    parser = argparse.ArgumentParser(
        description="Estimate monthly S3 bucket storage costs",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  AWS_PROFILE=homelab python s3_cost_estimator.py my-bucket
  AWS_PROFILE=homelab python s3_cost_estimator.py my-bucket --region us-west-2
        """,
    )
    parser.add_argument("bucket", help="S3 bucket name")
    parser.add_argument(
        "--region",
        help="AWS region for pricing (auto-detected if not specified)",
        default=None,
    )
    parser.add_argument(
        "--profile",
        help="AWS profile to use (can also use AWS_PROFILE env var)",
        default=None,
    )
    parser.add_argument(
        "--no-comparison",
        action="store_true",
        help="Skip the disk storage comparison",
    )

    args = parser.parse_args()

    # Create session with profile if specified
    try:
        session_kwargs = {}
        if args.profile:
            session_kwargs["profile_name"] = args.profile

        session = boto3.Session(**session_kwargs)
        s3_client = session.client("s3")
    except ProfileNotFound as e:
        print(f"Error: {e}")
        sys.exit(1)
    except NoCredentialsError:
        print("Error: No AWS credentials found. Set AWS_PROFILE or configure credentials.")
        sys.exit(1)

    bucket_name = args.bucket

    # Verify bucket exists and is accessible
    try:
        s3_client.head_bucket(Bucket=bucket_name)
    except ClientError as e:
        error_code = e.response.get("Error", {}).get("Code", "Unknown")
        if error_code == "404":
            print(f"Error: Bucket '{bucket_name}' does not exist.")
        elif error_code == "403":
            print(f"Error: Access denied to bucket '{bucket_name}'.")
        else:
            print(f"Error accessing bucket: {e}")
        sys.exit(1)

    # Get bucket region
    region = args.region or get_bucket_region(s3_client, bucket_name)
    print(f"Analyzing bucket '{bucket_name}' in region '{region}'...")

    # Get storage metrics
    print("Listing objects (this may take a while for large buckets)...")
    metrics = get_storage_metrics(s3_client, bucket_name)

    if metrics["total_objects"] == 0:
        print(f"\nBucket '{bucket_name}' is empty. No storage costs.")
        sys.exit(0)

    # Calculate costs
    costs = calculate_costs(metrics, region)

    # Print report
    print_report(bucket_name, region, costs, show_comparison=not args.no_comparison)


if __name__ == "__main__":
    main()
