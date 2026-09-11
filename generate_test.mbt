///|
test "seeded generation always replays to its exact goal" {
  let (b, _) = triangle_board(5, 0)
  for seed = 0; seed < 100; seed = seed + 1 {
    let g : Position = { bits: 1UL }
    let puzzle = b.generate(g, 8, seed.reinterpret_as_uint())
    assert_true(b.verify_solution(puzzle.start, puzzle.solution, Exact(g)))
    assert_eq(puzzle.start.count(), puzzle.solution.length() + 1)
    assert_eq(puzzle, b.generate(g, 8, seed.reinterpret_as_uint()))
  }
}

///|
test "requested depth is never claimed when inverse walk gets stuck" {
  let (b, p) = parse_board("o..")
  let x = b.generate(p, 2, 0U)
  assert_false(x.reached_depth)
  assert_eq(x.solution.length(), 1)
  assert_true(b.verify_solution(x.start, x.solution, Exact(p)))
  let y = b.generate(p, 0, 0U)
  assert_true(y.reached_depth)
  assert_eq(y.start, p)
  try b.generate(p, 3, 0U) catch {
    e => assert_true(e is InvalidBudget)
  } noraise {
    _ => fail("invalid depth")
  }
}
