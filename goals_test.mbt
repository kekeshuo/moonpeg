///|
test "terminal is not synonymous with solved" {
  let (b, p) = parse_board("o.o")
  assert_true(b.is_terminal(p))
  assert_false(b.is_goal(p, AnySingle))
  assert_true(b.is_goal(p, Exact(p)))
  let q : Position = { bits: 1UL }
  assert_true(b.is_goal(q, b.goal_at(0, 0)))
  assert_false(b.is_goal(q, b.goal_at(2, 0)))
}

///|
test "empty foreign and absent-hole goals rejected" {
  let (b, _) = parse_board("o#.")
  let positions : Array[Position] = [{ bits: 0UL }, { bits: 4UL }]
  for p in positions {
    try b.validate_goal(Exact(p)) catch {
      e => assert_true(e is InvalidGoal)
    } noraise {
      _ => fail("invalid goal accepted")
    }
  }
  try b.goal_at(1, 0) catch {
    _ => ()
  } noraise {
    _ => fail("missing hole accepted")
  }
}
