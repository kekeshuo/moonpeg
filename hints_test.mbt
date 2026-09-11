///|
test "hints include the opening move in replayable certificates" {
  let (b, p) = triangle_board(5, 0)
  let hints = b.hints(p, AnySingle, 100000)
  assert_eq(hints.length(), 2)
  let mut visited = 0
  for h in hints {
    visited = visited + h.report.visited
    match h.report.outcome {
      Solved(ids) => {
        assert_eq(ids[0], h.move_id)
        assert_true(b.verify_solution(p, ids, AnySingle))
      }
      _ => ()
    }
  }
  assert_true(visited <= 100000)
}

///|
test "zero budget may still identify immediate winning move" {
  let (b, p) = parse_board("oo.")
  assert_eq(b.hints(p, AnySingle, 0)[0].report.outcome, Solved([0]))
  let (c, q) = triangle_board(5, 0)
  for h in c.hints(q, AnySingle, 0) {
    assert_eq(h.report.outcome, Exhausted)
    assert_eq(h.report.visited, 0)
  }
}
