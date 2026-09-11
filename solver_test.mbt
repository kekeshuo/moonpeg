///|
test "solve certifies result and honors exact budget boundary" {
  let (b, p) = parse_board("oo.")
  assert_eq(b.solve(p, AnySingle, 0).outcome, Exhausted)
  let r = b.solve(p, AnySingle, 1)
  match r.outcome {
    Solved(ids) => assert_true(b.verify_solution(p, ids, AnySingle))
    _ => fail("solution expected")
  }
  assert_eq(r.visited, 1)
  assert_eq(b.solve({ bits: 1UL }, AnySingle, 0).outcome, Solved([]))
}

///|
test "unsolvable and exhausted cannot be confused" {
  let (b, p) = parse_board("o.o")
  assert_eq(b.solve(p, AnySingle, 1).outcome, Unsolvable)
  assert_eq(b.solve(p, AnySingle, 0).outcome, Exhausted)
  for n in [-1, 1000001] {
    try b.solve(p, AnySingle, n) catch {
      e => assert_true(e is InvalidBudget)
    } noraise {
      _ => fail("budget accepted")
    }
  }
}

///|
test "triangular puzzle yields an independently replayable certificate" {
  let (b, p) = triangle_board(5, 0)
  let r = b.solve(p, AnySingle, 100000)
  match r.outcome {
    Solved(ids) => {
      assert_eq(ids.length(), 13)
      assert_true(b.verify_solution(p, ids, AnySingle))
    }
    _ => fail("triangle solution expected")
  }
}
