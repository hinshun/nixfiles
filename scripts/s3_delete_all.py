#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["boto3"]
# ///
"""Delete all objects (including versions) in an S3 bucket."""

import argparse
import boto3


def delete_all_objects(bucket_name: str, prefix: str = "", dry_run: bool = False):
    """Delete all objects and versions in a bucket, optionally filtered by prefix."""
    s3 = boto3.client("s3")

    # Check if versioning is enabled
    versioning = s3.get_bucket_versioning(Bucket=bucket_name)
    is_versioned = versioning.get("Status") in ("Enabled", "Suspended")

    if is_versioned:
        print(f"Bucket has versioning {versioning.get('Status')}, deleting all versions...")
        paginator = s3.get_paginator("list_object_versions")
    else:
        print("Bucket is not versioned, deleting objects...")
        paginator = s3.get_paginator("list_objects_v2")

    params = {"Bucket": bucket_name}
    if prefix:
        params["Prefix"] = prefix

    total_deleted = 0

    for page in paginator.paginate(**params):
        objects = []

        # Handle versioned objects
        for obj in page.get("Versions", []):
            objects.append({"Key": obj["Key"], "VersionId": obj["VersionId"]})

        # Handle delete markers
        for obj in page.get("DeleteMarkers", []):
            objects.append({"Key": obj["Key"], "VersionId": obj["VersionId"]})

        # Handle non-versioned objects
        for obj in page.get("Contents", []):
            objects.append({"Key": obj["Key"]})

        if not objects:
            continue

        if dry_run:
            for obj in objects:
                version = obj.get("VersionId", "")
                print(f"Would delete: {obj['Key']}" + (f" (version: {version})" if version else ""))
            total_deleted += len(objects)
        else:
            response = s3.delete_objects(
                Bucket=bucket_name,
                Delete={"Objects": objects, "Quiet": True},
            )
            deleted = len(response.get("Deleted", []))
            total_deleted += deleted
            print(f"Deleted {deleted} objects...")

            if "Errors" in response:
                for error in response["Errors"]:
                    print(f"Error deleting {error['Key']}: {error['Message']}")

    print(f"\nTotal: {total_deleted} objects {'would be ' if dry_run else ''}deleted")


def main():
    parser = argparse.ArgumentParser(description="Delete all objects in an S3 bucket")
    parser.add_argument("bucket", help="S3 bucket name")
    parser.add_argument("--prefix", default="", help="Only delete objects with this prefix")
    parser.add_argument("--dry-run", action="store_true", help="List objects without deleting")
    args = parser.parse_args()

    if not args.dry_run:
        confirm = input(f"Delete all objects in s3://{args.bucket}/{args.prefix}? [y/N] ")
        if confirm.lower() != "y":
            print("Aborted")
            return

    delete_all_objects(args.bucket, args.prefix, args.dry_run)


if __name__ == "__main__":
    main()
