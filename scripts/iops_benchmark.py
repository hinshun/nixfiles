#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""
IOPS Benchmark Tool

Measures read/write IOPS and latency for a given directory/filesystem.
Uses 4KB block size (industry standard for IOPS measurement).

Usage: uv run iops_benchmark.py /path/to/test/directory
"""

import argparse
import os
import random
import statistics
import sys
import tempfile
import time
from pathlib import Path


# Standard block size for IOPS testing
BLOCK_SIZE = 4096  # 4KB


def check_direct_io_support(test_file: Path) -> bool:
    """Check if O_DIRECT is supported on this filesystem."""
    if not hasattr(os, "O_DIRECT"):
        return False
    try:
        fd = os.open(str(test_file), os.O_RDONLY | os.O_DIRECT)
        os.close(fd)
        return True
    except OSError:
        return False


def create_aligned_buffer(size: int) -> bytearray:
    """Create a buffer aligned to 4KB for O_DIRECT."""
    # For O_DIRECT, buffer must be aligned to 512 bytes (or 4KB to be safe)
    return bytearray(size)


def benchmark_sequential_write(
    test_file: Path, size_mb: int, use_direct: bool
) -> dict:
    """Benchmark sequential write performance."""
    total_bytes = size_mb * 1024 * 1024
    num_ops = total_bytes // BLOCK_SIZE
    data = create_aligned_buffer(BLOCK_SIZE)
    for i in range(0, BLOCK_SIZE, 8):
        data[i:i+8] = random.randbytes(8)

    base_flags = os.O_WRONLY | os.O_CREAT | os.O_TRUNC
    actual_direct = False
    fd = None

    # Try with O_DIRECT first if requested
    if use_direct and hasattr(os, "O_DIRECT"):
        try:
            fd = os.open(str(test_file), base_flags | os.O_DIRECT, 0o644)
            # Try a test write to make sure O_DIRECT actually works
            os.write(fd, data)
            os.lseek(fd, 0, os.SEEK_SET)
            os.ftruncate(fd, 0)
            actual_direct = True
        except OSError:
            if fd is not None:
                os.close(fd)
            fd = None

    # Fall back to buffered I/O
    if fd is None:
        try:
            fd = os.open(str(test_file), base_flags, 0o644)
        except OSError as e:
            return {"error": str(e)}

    latencies = []

    try:
        start_time = time.perf_counter()
        for _ in range(num_ops):
            op_start = time.perf_counter()
            os.write(fd, data)
            op_end = time.perf_counter()
            latencies.append((op_end - op_start) * 1000)  # ms

        # Always fsync to ensure data hits disk
        os.fsync(fd)

        end_time = time.perf_counter()
    except OSError as e:
        os.close(fd)
        return {"error": str(e)}

    os.close(fd)

    elapsed = end_time - start_time
    iops = num_ops / elapsed
    throughput_mb = (num_ops * BLOCK_SIZE) / elapsed / (1024 * 1024)

    return {
        "iops": iops,
        "throughput_mb_s": throughput_mb,
        "avg_latency_ms": statistics.mean(latencies),
        "p99_latency_ms": statistics.quantiles(latencies, n=100)[98] if len(latencies) > 100 else max(latencies),
        "total_ops": num_ops,
        "elapsed_s": elapsed,
        "direct_io": actual_direct,
    }


def benchmark_sequential_read(test_file: Path, use_direct: bool) -> dict:
    """Benchmark sequential read performance."""
    file_size = test_file.stat().st_size
    num_ops = file_size // BLOCK_SIZE

    if num_ops == 0:
        return {"error": "Test file is empty"}

    # Drop caches if possible (requires root)
    try:
        with open("/proc/sys/vm/drop_caches", "w") as f:
            f.write("3")
    except (PermissionError, FileNotFoundError):
        pass  # Not running as root or not Linux

    base_flags = os.O_RDONLY
    actual_direct = False
    fd = None

    # Try with O_DIRECT first if requested
    if use_direct and hasattr(os, "O_DIRECT"):
        try:
            fd = os.open(str(test_file), base_flags | os.O_DIRECT)
            # Try a test read to make sure O_DIRECT actually works
            os.read(fd, BLOCK_SIZE)
            os.lseek(fd, 0, os.SEEK_SET)
            actual_direct = True
        except OSError:
            if fd is not None:
                os.close(fd)
            fd = None

    # Fall back to buffered I/O
    if fd is None:
        try:
            fd = os.open(str(test_file), base_flags)
        except OSError as e:
            return {"error": str(e)}

    latencies = []

    try:
        start_time = time.perf_counter()
        for _ in range(num_ops):
            op_start = time.perf_counter()
            data = os.read(fd, BLOCK_SIZE)
            op_end = time.perf_counter()
            if not data:
                break
            latencies.append((op_end - op_start) * 1000)

        end_time = time.perf_counter()
    except OSError as e:
        os.close(fd)
        return {"error": str(e)}

    os.close(fd)

    elapsed = end_time - start_time
    actual_ops = len(latencies)
    iops = actual_ops / elapsed if elapsed > 0 else 0
    throughput_mb = (actual_ops * BLOCK_SIZE) / elapsed / (1024 * 1024) if elapsed > 0 else 0

    return {
        "iops": iops,
        "throughput_mb_s": throughput_mb,
        "avg_latency_ms": statistics.mean(latencies) if latencies else 0,
        "p99_latency_ms": statistics.quantiles(latencies, n=100)[98] if len(latencies) > 100 else (max(latencies) if latencies else 0),
        "total_ops": actual_ops,
        "elapsed_s": elapsed,
        "direct_io": actual_direct,
    }


def benchmark_random_write(test_file: Path, num_ops: int, use_direct: bool) -> dict:
    """Benchmark random write IOPS (the most important metric)."""
    file_size = test_file.stat().st_size
    max_offset = (file_size // BLOCK_SIZE) - 1

    if max_offset <= 0:
        return {"error": "File too small for random I/O test"}

    data = create_aligned_buffer(BLOCK_SIZE)
    for i in range(0, BLOCK_SIZE, 8):
        data[i:i+8] = random.randbytes(8)

    base_flags = os.O_WRONLY
    actual_direct = False
    fd = None

    # Try with O_DIRECT first if requested
    if use_direct and hasattr(os, "O_DIRECT"):
        try:
            fd = os.open(str(test_file), base_flags | os.O_DIRECT)
            # Try a test write
            os.write(fd, data)
            os.lseek(fd, 0, os.SEEK_SET)
            actual_direct = True
        except OSError:
            if fd is not None:
                os.close(fd)
            fd = None

    # Fall back to buffered I/O
    if fd is None:
        try:
            fd = os.open(str(test_file), base_flags)
        except OSError as e:
            return {"error": str(e)}

    # Pre-generate random offsets
    offsets = [random.randint(0, max_offset) * BLOCK_SIZE for _ in range(num_ops)]
    latencies = []

    try:
        start_time = time.perf_counter()
        for offset in offsets:
            op_start = time.perf_counter()
            os.lseek(fd, offset, os.SEEK_SET)
            os.write(fd, data)
            op_end = time.perf_counter()
            latencies.append((op_end - op_start) * 1000)

        # Always fsync to measure true write performance
        os.fsync(fd)

        end_time = time.perf_counter()
    except OSError as e:
        os.close(fd)
        return {"error": str(e)}

    os.close(fd)

    elapsed = end_time - start_time
    iops = num_ops / elapsed

    return {
        "iops": iops,
        "avg_latency_ms": statistics.mean(latencies),
        "p99_latency_ms": statistics.quantiles(latencies, n=100)[98] if len(latencies) > 100 else max(latencies),
        "min_latency_ms": min(latencies),
        "max_latency_ms": max(latencies),
        "total_ops": num_ops,
        "elapsed_s": elapsed,
        "direct_io": actual_direct,
    }


def benchmark_random_read(test_file: Path, num_ops: int, use_direct: bool) -> dict:
    """Benchmark random read IOPS."""
    file_size = test_file.stat().st_size
    max_offset = (file_size // BLOCK_SIZE) - 1

    if max_offset <= 0:
        return {"error": "File too small for random I/O test"}

    # Drop caches if possible
    try:
        with open("/proc/sys/vm/drop_caches", "w") as f:
            f.write("3")
    except (PermissionError, FileNotFoundError):
        pass

    base_flags = os.O_RDONLY
    actual_direct = False
    fd = None

    # Try with O_DIRECT first if requested
    if use_direct and hasattr(os, "O_DIRECT"):
        try:
            fd = os.open(str(test_file), base_flags | os.O_DIRECT)
            # Try a test read
            os.read(fd, BLOCK_SIZE)
            os.lseek(fd, 0, os.SEEK_SET)
            actual_direct = True
        except OSError:
            if fd is not None:
                os.close(fd)
            fd = None

    # Fall back to buffered I/O
    if fd is None:
        try:
            fd = os.open(str(test_file), base_flags)
        except OSError as e:
            return {"error": str(e)}

    # Pre-generate random offsets
    offsets = [random.randint(0, max_offset) * BLOCK_SIZE for _ in range(num_ops)]
    latencies = []

    try:
        start_time = time.perf_counter()
        for offset in offsets:
            op_start = time.perf_counter()
            os.lseek(fd, offset, os.SEEK_SET)
            os.read(fd, BLOCK_SIZE)
            op_end = time.perf_counter()
            latencies.append((op_end - op_start) * 1000)

        end_time = time.perf_counter()
    except OSError as e:
        os.close(fd)
        return {"error": str(e)}

    os.close(fd)

    elapsed = end_time - start_time
    iops = num_ops / elapsed

    return {
        "iops": iops,
        "avg_latency_ms": statistics.mean(latencies),
        "p99_latency_ms": statistics.quantiles(latencies, n=100)[98] if len(latencies) > 100 else max(latencies),
        "min_latency_ms": min(latencies),
        "max_latency_ms": max(latencies),
        "total_ops": num_ops,
        "elapsed_s": elapsed,
        "direct_io": actual_direct,
    }


def get_filesystem_info(path: Path) -> dict:
    """Get filesystem information for the given path."""
    info = {}

    try:
        stat = os.statvfs(path)
        info["total_gb"] = (stat.f_blocks * stat.f_frsize) / (1024**3)
        info["free_gb"] = (stat.f_bavail * stat.f_frsize) / (1024**3)
        info["block_size"] = stat.f_bsize
    except OSError:
        pass

    # Try to get mount info on Linux
    try:
        with open("/proc/mounts") as f:
            path_str = str(path.resolve())
            best_match = ""
            best_info = None
            for line in f:
                parts = line.split()
                if len(parts) >= 3:
                    mount_point = parts[1]
                    if path_str.startswith(mount_point) and len(mount_point) > len(best_match):
                        best_match = mount_point
                        best_info = {
                            "device": parts[0],
                            "mount_point": parts[1],
                            "fs_type": parts[2],
                        }
            if best_info:
                info.update(best_info)
    except (FileNotFoundError, PermissionError):
        pass

    return info


def print_results(name: str, results: dict):
    """Print benchmark results."""
    if "error" in results:
        print(f"  ERROR: {results['error']}")
        return

    direct_str = ""
    if "direct_io" in results:
        direct_str = " (direct)" if results["direct_io"] else " (buffered)"

    print(f"  IOPS:          {results['iops']:,.0f}{direct_str}")
    if "throughput_mb_s" in results:
        print(f"  Throughput:    {results['throughput_mb_s']:.1f} MB/s")
    print(f"  Avg Latency:   {results['avg_latency_ms']:.3f} ms")
    print(f"  P99 Latency:   {results['p99_latency_ms']:.3f} ms")
    if "min_latency_ms" in results:
        print(f"  Min Latency:   {results['min_latency_ms']:.3f} ms")
        print(f"  Max Latency:   {results['max_latency_ms']:.3f} ms")
    print(f"  Total Ops:     {results['total_ops']:,}")
    print(f"  Duration:      {results['elapsed_s']:.2f}s")


def main():
    parser = argparse.ArgumentParser(
        description="Benchmark IOPS and throughput for a filesystem",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  uv run iops_benchmark.py /mnt/data
  uv run iops_benchmark.py /tmp --size 256 --ops 5000
  uv run iops_benchmark.py . --quick

Note: For accurate results, run with sudo to drop filesystem caches.
For production benchmarks, use 'fio' instead.
        """,
    )
    parser.add_argument("directory", help="Directory to benchmark (must be writable)")
    parser.add_argument(
        "--size",
        type=int,
        default=128,
        help="Test file size in MB (default: 128)",
    )
    parser.add_argument(
        "--ops",
        type=int,
        default=2000,
        help="Number of random I/O operations (default: 2000)",
    )
    parser.add_argument(
        "--quick",
        action="store_true",
        help="Quick test with smaller file and fewer ops",
    )
    parser.add_argument(
        "--keep",
        action="store_true",
        help="Keep test file after benchmark",
    )
    parser.add_argument(
        "--no-direct",
        action="store_true",
        help="Disable O_DIRECT (use OS cache)",
    )

    args = parser.parse_args()

    if args.quick:
        args.size = 32
        args.ops = 500

    test_dir = Path(args.directory).resolve()

    if not test_dir.exists():
        print(f"Error: Directory '{test_dir}' does not exist")
        sys.exit(1)

    if not test_dir.is_dir():
        print(f"Error: '{test_dir}' is not a directory")
        sys.exit(1)

    # Check write permission
    test_file = test_dir / f".iops_benchmark_{os.getpid()}.tmp"

    print("=" * 60)
    print("IOPS BENCHMARK")
    print("=" * 60)
    print(f"\nTarget:     {test_dir}")

    # Get filesystem info
    fs_info = get_filesystem_info(test_dir)
    if fs_info:
        if "device" in fs_info:
            print(f"Device:     {fs_info['device']}")
        if "fs_type" in fs_info:
            print(f"Filesystem: {fs_info['fs_type']}")
        if "total_gb" in fs_info:
            print(f"Capacity:   {fs_info['total_gb']:.1f} GB ({fs_info['free_gb']:.1f} GB free)")
        if "block_size" in fs_info:
            print(f"Block Size: {fs_info['block_size']} bytes")

    print(f"\nTest file:  {args.size} MB")
    print(f"Block size: {BLOCK_SIZE} bytes (4 KB)")
    print(f"Random ops: {args.ops}")

    use_direct = not args.no_direct
    print(f"O_DIRECT:   {'Requested (may fall back to buffered)' if use_direct else 'Disabled'}")

    try:
        # Sequential Write
        print("\n" + "-" * 60)
        print("SEQUENTIAL WRITE")
        print("-" * 60)
        seq_write = benchmark_sequential_write(test_file, args.size, use_direct)
        print_results("Sequential Write", seq_write)

        # Sequential Read
        print("\n" + "-" * 60)
        print("SEQUENTIAL READ")
        print("-" * 60)
        seq_read = benchmark_sequential_read(test_file, use_direct)
        print_results("Sequential Read", seq_read)

        # Random Write
        print("\n" + "-" * 60)
        print("RANDOM WRITE (4K) - Most important for databases/games")
        print("-" * 60)
        rand_write = benchmark_random_write(test_file, args.ops, use_direct)
        print_results("Random Write", rand_write)

        # Random Read
        print("\n" + "-" * 60)
        print("RANDOM READ (4K)")
        print("-" * 60)
        rand_read = benchmark_random_read(test_file, args.ops, use_direct)
        print_results("Random Read", rand_read)

        # Summary
        print("\n" + "=" * 60)
        print("SUMMARY")
        print("=" * 60)

        if "error" not in rand_write and "error" not in rand_read:
            print(f"\n{'Metric':<25} {'Read':>12} {'Write':>12}")
            print("-" * 50)
            print(f"{'Random 4K IOPS':<25} {rand_read['iops']:>12,.0f} {rand_write['iops']:>12,.0f}")
            print(f"{'Avg Latency (ms)':<25} {rand_read['avg_latency_ms']:>12.3f} {rand_write['avg_latency_ms']:>12.3f}")

            if "error" not in seq_read and "error" not in seq_write:
                print(f"{'Sequential (MB/s)':<25} {seq_read['throughput_mb_s']:>12.1f} {seq_write['throughput_mb_s']:>12.1f}")

            # Performance assessment
            print("\n" + "-" * 50)
            print("ASSESSMENT:")
            print("-" * 50)

            rand_iops = min(rand_read.get("iops", 0), rand_write.get("iops", 0))

            if rand_iops >= 50000:
                rating = "Excellent (NVMe SSD)"
            elif rand_iops >= 10000:
                rating = "Great (Fast SSD)"
            elif rand_iops >= 3000:
                rating = "Good (SATA SSD)"
            elif rand_iops >= 500:
                rating = "Fair (Fast HDD / Slow SSD)"
            elif rand_iops >= 100:
                rating = "Poor (HDD)"
            else:
                rating = "Very Poor (Network storage / Slow HDD)"

            print(f"Performance tier: {rating}")

            # Minecraft assessment
            if rand_iops >= 1000:
                mc = "Excellent for Minecraft"
            elif rand_iops >= 300:
                mc = "Good for Minecraft (small servers)"
            elif rand_iops >= 100:
                mc = "Marginal for Minecraft (may have chunk lag)"
            else:
                mc = "Not recommended for Minecraft"

            print(f"Minecraft suitability: {mc}")

    finally:
        if not args.keep and test_file.exists():
            test_file.unlink()
            print(f"\nCleaned up test file: {test_file}")
        elif args.keep and test_file.exists():
            print(f"\nTest file kept: {test_file}")


if __name__ == "__main__":
    main()
