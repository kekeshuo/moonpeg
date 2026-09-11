# From a board to a verified puzzle

Run `moon run examples/solve --target wasm-gc` from the project root. The same pure
example runs on `wasm`, `js`, and `native` (with a C compiler).

The 15-hole triangle starts with an empty apex. A triangular lattice uses the horizontal,
vertical and `(1,1)` axes in axial coordinates, **not** all eight square-grid neighbors.
The example solves it within 100000 expanded nodes, replays the entire solution, and
asserts that the result has one peg. Then it starts from an exact apex goal and performs
up to eight inverse jumps using seed 42, returning a forward solution certificate.
This generates reachable puzzles by construction; it does not certify difficulty.

## Use from another MoonBit package

Add a local dependency while unpublished, or a MoonCakes dependency only after manual
publication. Import `kekeshuo/moonpeg` with alias `peg` in your package manifest.
The complete compiling example is `examples/solve/main.mbt`. Key calls are:

```moonbit
let (board, start) = @peg.parse_board("oo.")
let result = board.solve(start, AnySingle, 100)
match result.outcome {
  Solved(moves) => assert_true(board.verify_solution(start, moves, AnySingle))
  Unsolvable => abort("this fixture is solvable")
  Exhausted => abort("increase budget, not an impossibility proof")
}
```

`Position` is an immutable UInt64 occupancy and `Board` owns validated hole/jump topology.
Use one board instance throughout a transcript. Returned hole/jump arrays are copies.
Directly constructed occupancy values are checked at every public board operation.

## CLI scenarios

Build once: `moon build --target js --release`.
Run: `node scripts/moonpeg.cjs examples/requests/triangle.json`.
All eight fixtures can be checked with `node scripts/examples.cjs`.

- `line.json`: smallest solvable puzzle, deterministic move `[0]`.
- `triangle.json`: solve the standard 15-hole triangular layout.
- `generate.json`: bounded inverse walk; `reached_depth` may be false on a stuck branch.
- `hints.json`: classify each legal opening with one shared budget.
- `replay.json`: validate the entire supplied certificate and show all states.
- `disconnected.json`: explain necessary jump-component/position-class obstructions.
- `impossible.json`: proven no legal solution (CLI exit 1).
- `exhausted.json`: no proof within the budget (CLI exit 3).

Always branch on status. Do not turn an exhausted search into “unsolvable”, and do not
interpret `terminal` as “solved”. `analyze` is a separate diagnostic operation; the DFS
currently does not automatically prune using its algebraic/component obstructions.
