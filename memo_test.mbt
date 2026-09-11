///|
test "memo and plain DFS agree on every five-hole line occupancy and goal" {
  let (b, _) = parse_board(".....")
  for n = 0; n < 32; n = n + 1 {
    let p : Position = { bits: n.to_uint64() }
    for goal_id = 0; goal_id < 5; goal_id = goal_id + 1 {
      let g = b.goal_at(goal_id, 0)
      let a = b.solve(p, g, 10000, memoize=false)
      let c = b.solve(p, g, 10000)
      assert_eq(a.outcome, c.outcome)
      assert_true(c.visited <= a.visited)
    }
  }
}

///|
test "dead states are cached but exhaustion does not poison future searches" {
  let (b, p) = triangle_board(5, 0)
  assert_eq(b.solve(p, AnySingle, 1).outcome, Exhausted)
  let r = b.solve(p, AnySingle, 100000)
  assert_true(r.cache_hits > 0)
  match r.outcome {
    Solved(ids) => assert_true(b.verify_solution(p, ids, AnySingle))
    _ => fail("expected solved")
  }
  assert_eq(b.solve(p, AnySingle, 1).outcome, Exhausted)
}
