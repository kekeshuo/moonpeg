# Contributing

Read docs/SCOPE.md and docs/ARCHITECTURE.md. Keep work peg-specific and reproducible. Use
codex/ branches for Codex work. Configure Git identity only in your own repository; verify the
intended account before push. Never run competing writers in one checkout or commit credentials.

Run python scripts/verify.py and python scripts/consumer-test.py. When no C compiler exists,
explicitly record native runtime as unverified with --skip-native-runtime. Review generated API
changes from moon info. Pair regressions with fixtures and fixes in coherent commits. Expand the
independent oracle for jump/goal/search changes. Do not count empty or artificial microcommits.

Preserve Exhausted vs Unsolvable, exact-goal symmetry, checked replay and bounds. Record external
provenance/licenses and AI assistance. Before release: run all checks, inspect hosted CI, verify
public repository/account/author mapping and tag agreement, and complete the participant application
outside Git. MoonCakes publication is a separate explicit operation, never automatic CI.
