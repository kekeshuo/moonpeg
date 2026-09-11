# Verification and reproducibility

Tested toolchain baseline: `moon 0.1.20260713`, `moonc v0.10.4+2cc641edf` (2026-07-15).
CI installs that fixed compiler/core version rather than silently floating to latest.
The official installer download is SHA-256 checked (reviewed 2026-09-11); action references
are immutable upstream commit SHAs. If the installer changes, CI fails closed until a
maintainer reviews and updates the hash. Compiler archives use the official versioned
HTTPS URLs; the installer hash does not separately pin archive contents.

```sh
python scripts/verify.py
# Windows without a C compiler: native strict check still runs, runtime is UNVERIFIED
python scripts/verify.py --skip-native-runtime --report ../research/local-verification.json
# one target, used by the Actions matrix
python scripts/verify.py --target js
```

The runner checks formatting, generated API drift, strict checks, release builds, unit
and negative tests, and the executable tutorial. JS additionally runs CLI subprocess
checks, eight public JSON fixtures and the independent oracle. It fails on the first
failed command and can persist exact output. Only an explicit flag skips native runtime;
CI never passes that flag. A GitHub workflow file is **not** evidence that hosted CI ran.

The independent Node oracle uses string occupancies and its own endpoint/midpoint jump
enumerator. It has no bitsets, symmetry, reverse generator or algebraic shortcuts. It
enumerates every occupancy of a six-hole line, 3x3 square, four-row triangle, disconnected
six-hole board, and irregular seven-hole board. For each it checks any-single, every
exact singleton and one exact two-peg goal: **20096 board/goal pairs**. Every solved path
is independently replayed; every claimed obstruction must agree with exhaustive search.
This is strong evidence for small boards, not a proof for every 64-hole board or a claim
of complete coverage. Core tests additionally exercise the high UInt64 bit, 64-hole parsing,
copy isolation, inverse roundtrips, exact-goal symmetry, budget semantics and seeded replay.

Performance claims are deliberately limited: the tutorial fixture expands 115 nodes on
the recorded baseline. Oracle elapsed time is diagnostic and machine-dependent, not a
cross-language benchmark. English 33-hole search can exhaust the configured budget.
