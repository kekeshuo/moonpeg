# MoonPeg duplication check

Date: 2026-09-11 (Asia/Shanghai). Decision: select original MoonPeg, not an approval or guaranteed competition acceptance.

## Procedure and limitations
Read the installed moonbit-hackathon-builder fixed September rules, environment preflight and permanent registry, and invoked the installed osc2026-guide Project Research Guide. The latter is an operational research aid, NOT organizer human review and NOT a replacement for the fixed September rules. `moon search --help` actually failed: the installed moon has no search subcommand. Replaced it with 25 live MoonCakes public search API queries; raw results retained outside the repository in ../research. GitHub clone connections failed; GitHub REST tree/content endpoints were used instead. Source inspection was scoped, not an exhaustive audit of the ecosystem.

## Three different candidates
|Candidate/domain|Core data and acceptance loop|Decision|
|---|---|---|
|MoonImpose / print production|page ordering, duplex sheet slots, booklet folding|Rejected: despite empty exact name searches, bobzhang/pdflite source contains pdf_impose, layout/core/helper functions. Do not rebrand existing capability.|
|MoonTuning / music theory|pitch ratios, scales, frequency mapping|Deferred: hyl-star/moonsic already has pitch/frequency/interval/scale semantics; independent necessity weaker.|
|MoonPeg / single-player puzzles|hole coordinates, occupancy, legal jump triples; generate/search/replay|Selected: specific state-transition domain distinct from other registry workflows; no direct peg-solitaire implementation found in inspected results.|

All complete existing registry records were loaded for comparison; their permanent boundaries remain in force. MoonPetri is the closest prior algorithmic neighbor, but its core is generic places/transitions/token counts and net reachability; MoonPeg is a specialized fixed-geometric jump board with binary occupancy, physical jump legality, inverse construction and goal-preserving geometric symmetry. Shared graph search/testing is engineering technique, not project identity. MoonWeave concerns warp/weft fabric cells, not puzzle occupancy or jump removal. Mahjong solitaire is pair matching, not jumping.

## Search evidence
MoonCakes keywords: MoonImpose, imposition, booklet, signature printing, duplex, cut stack, printing, pdf, pagelayout, sheet folding, MoonTuning, microtonal, music tuning, scala scale, MoonPeg, peg solitaire, solitaire, peg, 跳珠, 孔明棋, 独立钻石棋, marble solitaire, English solitaire, board solver.
Exact imposition/booklet and peg-solitaire phrases returned empty lists. This alone was NOT treated as novelty evidence. `solitaire` returned Mahjong; `board solver` returned general pathfinding/algorithms and games. All are examined as adjacent categories rather than discarded by name.
GitHub repository queries `imposition language:MoonBit`, `booklet MoonBit`, `"peg solitaire" MoonBit` are recorded in ../research/github-*.json. Repository search is not full code search.

|Package/version|Owner, maintenance signal|Capability and scoped conclusion|
|---|---|---|
|[bobzhang/pdflite@0.1.41](https://mooncakes.io/docs/bobzhang/pdflite)|[bobzhang](https://github.com/bobzhang/pdflite), pushed 2026-09-09, not archived|PDF imposition source found; printing candidate rejected.|
|[bobzhang/pagelayout@0.1.1](https://mooncakes.io/docs/bobzhang/pagelayout)|[moonbitlang/office.mbt](https://github.com/moonbitlang/office.mbt), pushed 2026-09-11, not archived|Page model/layout, not peg occupancy search.|
|[hyl-star/moonsic@0.1.0](https://mooncakes.io/docs/hyl-star/moonsic)|[hyl-star/moonsic](https://github.com/hyl-star/moonsic), pushed 2026-07-12, not archived|Read README architecture: pitch, scales, interval and music IR. Music candidate deferred.|
|[bobzhang/games@0.9.33](https://mooncakes.io/docs/bobzhang/games)|[bobzhang/games](https://github.com/bobzhang/games)|Complete returned source tree (truncated=false), Mahjong solitaire game logic inspected. Pair removal and free-tile matching, no peg-jump package found by tree-name scan. Full game corpus NOT audited.|
|[Suquster/moonbit-pathfinding](https://mooncakes.io/docs/Suquster/moonbit-pathfinding)|[source](https://github.com/Suquster/moonbit-pathfinding)|README/source tree: general navigation/graph algorithms. Do not reimplement a graph library; the proposed reusable API is peg-specific.|

Newly discovered packages were appended to the permanent registry at metadata level, with source-reviewed ones distinguished. No external code or fixtures are copied into MoonPeg. Recheck prior to final submission. Duplication checking is separate from MoonCakes publication; nothing has been published.
