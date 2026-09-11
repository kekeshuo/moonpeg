# Third-party notices and origin

MoonPeg source, fixtures, CLI, oracle and documentation were created for this project. No external
peg-solitaire implementation, third-party board dataset, image or game asset was copied. Standard
board geometries and general algorithms are implemented from mathematical definitions. No upstream
port or vendored implementation is included.

- Runtime: [MoonBit core](https://github.com/moonbitlang/core), 0.10.4+2cc641edf, Apache-2.0.
  Built-in types, maps, strings and JSON parser/stringifier; not vendored.
- Toolchain: official MoonBit binaries and installer. CI downloads a reviewed SHA-pinned installer;
  it is not copied into this repository. Archive contents are not separately hash-pinned.
- Host tools: Node.js standard modules and Python standard library; no npm/pip dependencies.
- CI: actions/checkout and actions/setup-node, MIT, referenced by upstream commit SHA.
- Research only: pdflite, pagelayout, moonsic, games and moonbit-pathfinding were inspected for
  overlap. They are not dependencies; no source or README prose was incorporated. Only metadata
  summaries are retained; external source snapshots remain outside this repository.

MIT covers MoonPeg's original work; upstream tools/libraries retain their licenses. Distribution
of bundled third-party runtimes would require their notices separately.
