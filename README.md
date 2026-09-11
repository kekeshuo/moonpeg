# MoonPeg

**Pure MoonBit peg-solitaire solving, inverse puzzle generation and replayable certificates.**

MoonPeg turns ASCII boards into checked geometric jumps, bounded search results and solutions
you can replay. For puzzle editors, teaching tools and offline generation pipelines—not a
general graph library or full game UI.

```text
oo.  -- jump 0 -->  ..o
```

## Features

- Immutable UInt64 occupancy: `o` peg, `.` empty hole, `#` absent; at most 8x8/64 holes.
- Orthogonal/triangular lattices; English 33-hole and triangular presets.
- Checked forward/inverse moves, exact/any-single goals, full transcript replay.
- Bounded deterministic DFS, dead-state cache and goal-preserving geometric symmetry.
- Separate GF(2) position-class and jump-component necessary reachability diagnostics.
- Shared-budget opening hints; seeded inverse generation with forward certificates.
- Portable coordinate steps, JSON v1 facade and bounded file/stdin Node CLI.

## Install and run locally

Prerequisites: MoonBit; Node.js 22+ for CLI/oracle; Python 3.8+ for engineering scripts. Native
execution additionally needs a C compiler. Install MoonBit from its [official download page](https://www.moonbitlang.com/download/).
Verified baseline: `moonc v0.10.4+2cc641edf`, `moon 0.1.20260713`; CI pins it.

**Published on MoonCakes:** [kekeshuo/moonpeg 0.1.0](https://mooncakes.io/docs/kekeshuo/moonpeg).
From an existing MoonBit consumer project, install the released library:

```sh
moon add kekeshuo/moonpeg@0.1.0
```

The registry download was verified in a fresh consumer with no local path dependency:
strict checking and actual core/protocol API tests passed on wasm-gc and js.
Use a source checkout for the bundled CLI, tutorial and engineering scripts below.

Clone the public source, then run from its root:

```sh
git clone https://github.com/kekeshuo/moonpeg.git
cd moonpeg
```

```sh
moon check --deny-warn
moon test
moon run examples/solve --target wasm-gc
moon build --target js --release
node scripts/moonpeg.cjs examples/requests/triangle.json
node scripts/examples.cjs
```

The tutorial solves the 15-hole triangle in 13 jumps (115 expanded nodes on the recorded
baseline), verifies every transition, then generates and verifies a nine-peg puzzle.
`node scripts/moonpeg.cjs --help` describes file/stdin usage and exit codes.

### Integrate the library

Use the registry dependency installed above. For local development instead, use a path
dependency in a separate consumer's `moon.mod.json`:

```json
{"name":"local/my_puzzle","deps":{"kekeshuo/moonpeg":{"path":"../moonpeg"}}}
```

Import `"kekeshuo/moonpeg" @peg` in its `moon.pkg`. Call from a raising function/test:

```moonbit
let (board, start) = @peg.parse_board("oo.")
match board.solve(start, AnySingle, 100).outcome {
  Solved(moves) => assert_true(board.verify_solution(start, moves, AnySingle))
  Unsolvable => abort("no solution")
  Exhausted => abort("unknown: increase budget")
}
```

`python scripts/consumer-test.py` verifies a separate local path-dependency consumer;
it does not test the registry download.
Generated APIs: [core](pkg.generated.mbti), [protocol](protocol/pkg.generated.mbti).
Compiling usage: [tutorial source](examples/solve/main.mbt).

## Contracts

| Area | Contract |
| --- | --- |
| Boards | Width/height 1..8; ASCII; LF/CRLF, optional final LF; no bare CR |
| Moves | Orthogonal axes; triangular adds `(1,1)`. Deterministic zero-based IDs |
| Goals | Any singleton or exact nonempty occupancy on the same topology |
| Search | 0..1000000 expanded non-goal nodes; goal checks/cache hits are free |
| Results | Solved includes a replayable path; Unsolvable means exhaustive proof; Exhausted means unknown |
| Generation | Up to holes-minus-goal-pegs inverse jumps; may stop early; no uniformity/difficulty claim |
| Certificates | At most 63 jumps; illegal step gives a zero-based transcript diagnostic |
| Transport | JSON: 16384 code units/depth 16; CLI: 65536 UTF-8 bytes; no lossy UInt64 payloads |

Board operations validate occupancies. Topology is opaque; returned collections are copies.
Positions do not carry board identity: do not reuse bits with different topology. Diagnostics
and DFS are separate; an empty obstruction list is not a solvability proof. Search is worst-case
exponential and synchronous; node budgets are not time limits. No full English-board solvability,
optimality/difficulty or exhaustive ecosystem-novelty claim.

## Verify

```sh
python scripts/verify.py
# Explicitly record unverified native runtime when no C compiler is installed:
python scripts/verify.py --skip-native-runtime
```

Local results: **43 tests on each of wasm-gc, wasm and js**; native strict check passed, but
native build/test/demo are unverified locally. Independent oracle: **20096 board/goal cases**,
1164 solutions independently replayed, 15606 necessary-obstruction checks. Eight request
fixtures and 11 CLI process cases pass. [Hosted acceptance run](https://github.com/kekeshuo/moonpeg/actions/runs/34613980106)
passed all four targets, including **native build, 43 tests and the executable tutorial**,
on Ubuntu 24.04. This hosted result does not imply a local Windows native test.
See [testing](docs/TESTING.md), [release verification](docs/RELEASING.md) and the
[historical local checkpoint](docs/competition/local-readiness.md).

## Documentation

[Tutorial](docs/TUTORIAL.md) · [JSON](docs/PROTOCOL.md) · [Architecture](docs/ARCHITECTURE.md) ·
[Duplication research](docs/competition/duplicate-check.md) · [Scope](docs/SCOPE.md) ·
[AI disclosure](AI_USAGE.md) · [Notices](THIRD_PARTY_NOTICES.md) · [Security](SECURITY.md) ·
[Contributing](CONTRIBUTING.md) · [Changelog](CHANGELOG.md)

Original implementation under [MIT](LICENSE); runtime dependencies are MoonBit core only.
[Public source](https://github.com/kekeshuo/moonpeg) ·
[CI runs](https://github.com/kekeshuo/moonpeg/actions) ·
[GitHub releases](https://github.com/kekeshuo/moonpeg/releases).
MoonCakes **0.1.0 was published on 2026-09-11**; its public build status is successful and
its archive checksum matches the verified release package. The published package and
`v0.1.0` tag retain their original source snapshot; this README on `main` includes later
publication-status updates. No competition submission or organizer acceptance is claimed.
The completed application and participant information remain outside this repository.
