#!/usr/bin/env python3
"""
Verify crytic-compile sourceList ordering against Forge build-info source IDs.

Usage:
    cd test/fuzzing  # or any Foundry project directory
    forge build --build-info
    crytic-compile . --export-format solc --export-dir crytic-export
    python ../../scripts/verify_sourcelist.py
"""
import json
import sys
from pathlib import Path


def main():
    # Find build-info files
    build_info_dir = Path("out/build-info")
    if not build_info_dir.exists():
        print("ERROR: out/build-info not found.")
        print("Run: forge build --build-info")
        return 1

    build_info_files = list(build_info_dir.glob("*.json"))
    if not build_info_files:
        print("ERROR: No build-info JSON files found.")
        return 1

    # Collect source IDs
    source_ids = {}
    for bf in build_info_files:
        with open(bf) as f:
            data = json.load(f)
        for path, info in data.get("output", {}).get("sources", {}).items():
            source_id = info.get("id")
            if source_id is not None:
                source_ids[source_id] = path.split("/")[-1]

    print(f"Found {len(source_ids)} source IDs in Forge build-info")

    # Read crytic-compile output
    combined_path = Path("crytic-export/combined_solc.json")
    if not combined_path.exists():
        print()
        print("ERROR: crytic-export/combined_solc.json not found.")
        print("Run: crytic-compile . --export-format solc --export-dir crytic-export")
        return 1

    with open(combined_path) as f:
        combined = json.load(f)

    source_list = combined.get("sourceList", [])
    print(f"Found {len(source_list)} entries in sourceList")
    print()

    # Compare
    print("=== Comparison ===")
    mismatches = []
    for source_id in sorted(source_ids.keys()):
        expected = source_ids[source_id]
        if source_id >= len(source_list):
            print(f"  sourceList[{source_id}]: MISSING (expected '{expected}')")
            mismatches.append(source_id)
            continue

        actual = source_list[source_id].split("/")[-1]
        if expected != actual:
            print(f"  sourceList[{source_id}]: expected '{expected}' but got '{actual}' - MISMATCH!")
            mismatches.append(source_id)
        else:
            print(f"  sourceList[{source_id}]: {actual} - OK")

    print()
    if mismatches:
        print(f"BUG DETECTED: {len(mismatches)} mismatches out of {len(source_ids)} sources")
        print()
        print("Fix: pip install git+https://github.com/Mike4751/crytic-compile.git@fix-foundry-sourcelist-order")
        return 1
    else:
        print("All sourceList indices match source IDs correctly!")
        return 0


if __name__ == "__main__":
    sys.exit(main())
