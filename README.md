# crytic-compile sourceList Ordering Bug - Minimal Reproduction

This repository demonstrates a bug in crytic-compile where `sourceList` indices in exported `combined_solc.json` don't match the source IDs in Solidity bytecode source maps.

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/Mike4751/crytic-compile-sourcelist-bug
cd crytic-compile-sourcelist-bug

# 2. Build from the fuzzing subdirectory (this triggers the bug)
cd test/fuzzing
forge build --build-info

# 3. Run crytic-compile with UNPATCHED version
crytic-compile . --export-format solc --export-dir crytic-export --foundry-ignore-compile

# 4. See the bug - sourceList indices don't match source IDs
python3 ../../scripts/verify_sourcelist.py
```

## The Bug

### Observed Behavior (Unpatched)

```
=== Source IDs from Forge ===
  ID 0: Main.sol
  ID 1: Base.sol
  ID 2: Helper.sol
  ...

=== sourceList from crytic-compile ===
  sourceList[0]: Base.sol      # WRONG - should be Main.sol!
  sourceList[1]: IPrice.sol    # WRONG - should be Base.sol!
  sourceList[2]: Main.sol      # WRONG - should be Helper.sol!
  ...

BUG CONFIRMED: 8 mismatches!
```

### After Fix

```
=== Comparison with PATCHED crytic-compile ===
  sourceList[0]: Main.sol - OK
  sourceList[1]: Base.sol - OK
  sourceList[2]: Helper.sol - OK
  ...

FIX VERIFIED: All sourceList indices match source IDs!
```

## Why This Structure Triggers the Bug

The key is having a **subdirectory with its own `foundry.toml`** that uses **relative paths** to the same dependencies:

```
project/
├── foundry.toml              # libs = ["node_modules", "lib"]
├── node_modules/@external/   # External deps
├── lib/mylib/                # Local lib
├── contracts/Main.sol
└── test/fuzzing/
    ├── foundry.toml          # libs = ["../../node_modules", "../../lib"]  <-- RELATIVE!
    └── FuzzTest.sol
```

When building from `test/fuzzing/`:
1. Forge resolves paths both absolutely and relatively
2. The same file can appear with different path representations
3. JSON key order differs from ID order
4. crytic-compile iterates JSON keys, producing misaligned sourceList

## The Fix

Install the patched version:

```bash
pip install git+https://github.com/Mike4751/crytic-compile.git@fix-foundry-sourcelist-order
```

The fix:
1. Sorts sources by ID before processing
2. Tracks source ID → filename mapping
3. Uses ID-ordered filenames for export

## Backwards Compatibility

The fix has been tested to ensure it doesn't break standard project structures.

### Two Separate Test Environments

This repo contains two **completely isolated** test environments:

```
crytic-compile-sourcelist-bug/
├── test/fuzzing/              # Bug trigger (8 files, relative paths)
│   ├── foundry.toml           # libs = ["../../node_modules", "../../lib"]
│   └── FuzzTest.sol
│
└── test-backwards-compat/     # Simple project (3 files, standard structure)
    ├── foundry.toml           # No libs - standalone
    └── src/
        ├── A.sol
        ├── B.sol
        └── C.sol
```

### Verification

**test/fuzzing** (8 files with relative paths):
```
Files compiled: 8
  ../../contracts/Main.sol
  ../../lib/mylib/Base.sol
  ../../lib/mylib/Helper.sol
  ../../node_modules/@external/interfaces/IOracle.sol
  ../../node_modules/@external/interfaces/IPrice.sol
  ...
```

**test-backwards-compat** (3 files, simple structure):
```
Files compiled: 3
  src/A.sol
  src/B.sol
  src/C.sol
```

### Results

| Environment | Files | Structure | Unpatched | Patched |
|-------------|-------|-----------|-----------|---------|
| test-backwards-compat | 3 | Standard | 0 mismatches | 0 mismatches ✓ |
| test/fuzzing | 8 | Relative paths | **8 mismatches** | 0 mismatches ✓ |
| Large project (~470 files) | 470 | Complex | **470 mismatches** | 0 mismatches ✓ |

**The fix resolves the bug without breaking backwards compatibility.**

## Files

```
├── contracts/Main.sol           # Main contract
├── lib/mylib/                   # Local library
│   ├── Base.sol
│   └── Helper.sol
├── node_modules/@external/      # External deps
│   └── interfaces/
│       ├── IOracle.sol
│       └── IPrice.sol
├── test/
│   └── fuzzing/                 # Bug trigger (relative paths)
│       ├── foundry.toml
│       └── FuzzTest.sol
├── test-backwards-compat/       # Backwards compatibility test
│   ├── foundry.toml
│   └── src/
│       ├── A.sol
│       ├── B.sol
│       └── C.sol
├── scripts/
│   └── verify_sourcelist.py
└── foundry.toml
```

## Impact

This bug causes:
- Echidna LCOV coverage reports to attribute coverage to wrong files
- Slither source location references to be incorrect
- Any tool using `combined_solc.json` sourceList to malfunction
