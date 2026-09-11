# Security and resource boundaries

MoonPeg is an offline puzzle library, not a hardened multi-tenant service. It does not fetch URLs,
evaluate input as code, read credentials or modify files from JSON. Only the CLI reads the explicitly
supplied file/stdin and writes results to stdout. Runtime operations require no network access.

Boards: 8x8/64 holes. Transcripts: 63 moves. Search: 1000000 expansions. JSON: 16384 code units,
depth 16. CLI: 65536 bytes, strict UTF-8. Public board operations reject out-of-mask occupancy;
invalid transitions do not mutate input. These limits do not guarantee latency or memory use.
Untrusted service hosts should isolate processes, impose time/memory limits and restrict file
access independently. Generation seeds are not cryptographically random.

For defects, retain minimal input, compiler version, target, actual and expected results. Contact
the maintainer privately where available; never include credentials or unrelated files. Private
GitHub advisories can be enabled after repository creation. No reporting address was invented.
