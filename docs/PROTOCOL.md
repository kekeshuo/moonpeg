# JSON protocol v1

The pure `kekeshuo/moonpeg/protocol` package exposes `handle(String) -> String`.
The Node CLI only reads UTF-8, calls compiled MoonBit, and translates status into an exit code.

Every request is one object: `version: 1`, `command`, `board` (ASCII). Optional `lattice`
is `orthogonal` (default) or `triangular`. Optional `goal` is `any` (default) or an ASCII
board with **exactly the same hole coordinates and dimensions**, and nonempty occupancy.
Boards use `o`, `.`, `#`; at most 8x8 and 64 holes. Strings are case-sensitive.

| command | extra fields | response |
| --- | --- | --- |
| analyze | none | legal move IDs, directed jump index triples, components, obstructions, goal/terminal flags |
| solve | budget (default 100000) | solved + moves/steps, unsolvable, or exhausted; visited/cache_hits |
| hints | budget (default 100000) | legal openings and child reports, sharing one total expansion budget |
| replay | moves (required integer array) | all rendered states, valid_solution boolean, coordinate steps |
| generate | depth (default 0), seed (default 1) | generated board, exact goal, moves/steps, reached_depth flag |

`generate` requires an exact goal. Its request board specifies topology; its occupancy is
not the generation start. Depth is 0..holes-goal-pegs; seed is 0..2147483647 in JSON
(the MoonBit API also supports the full UInt32 range). Search budget is 0..1000000.
Move IDs are zero-based, deterministic for the supplied board/lattice; at most 63 moves.
`steps` are `[[from_x,from_y],[to_x,to_y]]`, zero-based, emitted for portable inspection.
The library's `decode_steps`/`verify_steps` consume the corresponding typed coordinates.
The JSON replay command accepts IDs, not coordinate arrays.

Unknown fields, wrong types, fractional/out-of-range integers, invalid topology and
illegal moves return `status: error` with stable `code` (`request`, `board`, `position`,
`goal`, `budget`, `transcript`, `move`; unexpected exceptions: `internal`). Transcript errors
include a zero-based step. Syntactically valid but unfinished replays return `ok` with
`valid_solution: false`, not a claim of solvability or impossibility.

Input is bounded to 16384 string code units and nesting depth 16 before JSON parsing.
The CLI additionally limits raw input to 65536 bytes and rejects invalid UTF-8.
JSON duplicate keys follow the core parser's last-value behavior; callers should avoid them.
No bitset is serialized as a JS number, avoiding 64-bit precision loss.

```sh
moon build --target js --release
node scripts/moonpeg.cjs examples/requests/line.json
# or pipe a single JSON request to stdin; not a streaming server
```

Exit codes: 0=ok/solved, 1=proven unsolvable, 2=invalid input/IO, 3=budget exhausted.
Empty obstruction lists mean only “not ruled out”; they are not proofs of solvability.
Budgets count expanded nodes, not elapsed time. For a service, add external time/memory
limits and isolate requests; the synchronous CLI is not a hardened multi-tenant server.
