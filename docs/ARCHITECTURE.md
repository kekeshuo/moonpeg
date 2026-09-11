# Architecture and correctness boundaries

## Packages and transitions

The root package owns puzzle logic. The protocol package converts bounded JSON to typed calls.
The JS bridge exports the protocol; the Node CLI supplies file/stdio only. The tutorial is a
cross-target executable. The host oracle deliberately has its own reference algorithm.

Hole IDs are row-major over present cells. A directed jump (from, over, to) requires occupied,
occupied, empty. XOR of those three bits gives the successor. Each jump removes exactly one
peg, so paths are acyclic and at most 63 steps. Inverse legality swaps these requirements;
reversing an inverse-walk ID list yields a forward certificate.

## Bounded search

Inputs are validated first. Goals are checked before expansion: zero budget can solve an already
finished position. The counter measures expanded non-goal, non-cached nodes. Budget exhaustion
propagates Exhausted, never Unsolvable. Only fully explored dead states enter the cache. Each
call owns its counter/map/stack: incomplete facts never persist. Space is O(budget + path depth),
apart from bounded topology/permutations.

Eight D4 candidates must preserve all holes and directed jumps. Exact-goal candidates must also
fix the target occupancy. Triangles use only the safe subset; full 60-degree symmetries are not
claimed. Only dead-state keys are canonicalized, never solution paths. Disabling symmetry and/or
memoization is supported for reference comparisons.

Hints search each legal opening, subtracting actual expansions from one shared budget. Solved
paths include the opening. These are move hints: an already-reached exact multi-peg goal may
still have legal openings; stopping now and moving again are distinct actions.

## Sound but incomplete obstructions

Each jump XOR mask is a vector in GF(2)^holes. Gaussian elimination builds their span's basis;
reducing occupancy modulo that span gives a conserved class. Exact goals must match that residue;
AnySingle must match at least one singleton. This ignores order and occupancy prerequisites,
so compatibility is necessary, not sufficient.

Components link the three holes of every jump, not all adjacent cells. Empty components cannot
become occupied; occupied components cannot lose their final peg. Exact per-component counts
cannot increase. Together with total peg-count reduction these yield sound obstruction strings.
They are separate diagnostics and do not prune DFS automatically.

## Generation and trust

A UInt32 LCG (1664525*x+1013904223 modulo 2^32) chooses an inverse-legal ID. Seeds are for
reproducibility, not cryptography. Walks may stop early with reached_depth=false; their actual
start and reversed path still certify the exact goal. No uniqueness, difficulty or uniformity claim.

The library has no IO or mutable global state. JSON bounds input before parsing, explicitly checks
integer values (core decoding may truncate fractions), and serializes boards rather than numeric64.
The CLI adds byte/UTF-8 limits. This is not a sandbox, server or formal proof assistant. Checked
replay and independent small-board agreement corroborate, but do not prove, all behavior.
