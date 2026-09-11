# Scope and reviewable milestones

One peg jumps over an adjacent peg into an empty hole; the jumped peg is removed. Orthogonal boards and triangular lattice boards are separate topologies. At most 64 holes; bounded dimensions, budgets and output. Original implementation using MoonBit core only.

Planned independently reviewable slices: (1) foundation, license and duplication gate; (2) board parser and occupancy; (3) compiled jumps and legal play; (4) reverse play; (5) board presets/lattices; (6) goals; (7) replay; (8) budgeted solver; (9) dead-state memoization; (10) topology/goal symmetry; (11) GF(2) reachability invariant; (12) disconnected-component constraints; (13) opening hints; (14) reverse puzzle generation; (15) move transcript codec; (16) JSON request facade; (17) executable CLI; (18) exhaustive independent oracle; (19) multi-target CI; (20) runnable tutorial and acceptance examples; (21) release/security/API documentation and actual evidence audit. Each feature is verified before committing; the final audit may exclude weak commits.

Non-goals: a generic graph or Petri-net library, arbitrary board games, Mahjong/card solitaire, graphical assets, network games, unbounded exhaustive search, minimum-move claims (all solutions to the same peg count have equal length), a guarantee of solvability for arbitrary standard boards.

Acceptance: invalid moves are rejected atomically; solved transcripts replay to a valid goal; impossible and unresolved results are never conflated; geometric symmetries preserve both topology and goal; negative and exhaustive small-board tests check the solver against an independent implementation.
