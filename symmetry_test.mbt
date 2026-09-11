///|
test "only board and goal stabilizing symmetries are used" {
  let (b, _) = english_board()
  assert_eq(b.symmetry_count(AnySingle), 8)
  assert_eq(b.symmetry_count(b.goal_at(3, 0)), 2)
  let (c, p) = parse_board("o..")
  let q : Position = { bits: 4UL }
  assert_eq(c.canonical(p, AnySingle), c.canonical(q, AnySingle))
  assert_false(
    c.canonical(p, c.goal_at(0, 0)) == c.canonical(q, c.goal_at(0, 0)),
  )
}

///|
test "canonicalization idempotent and solver outcome preserved on square" {
  let (b, _) = parse_board("...\n...\n...")
  for n = 0; n < 512; n = n + 1 {
    let p : Position = { bits: n.to_uint64() }
    let q = b.canonical(p, AnySingle)
    assert_eq(b.canonical(q, AnySingle), q)
    assert_eq(q.count(), p.count())
    let plain = b.solve(p, AnySingle, 10000, symmetry=false)
    let sym = b.solve(p, AnySingle, 10000)
    assert_eq(plain.outcome, sym.outcome)
  }
}

///|
test "asymmetric topology never gains invalid reflection" {
  let (b, _) = parse_board("...\no##")
  assert_eq(b.symmetry_count(AnySingle), 1)
  let (t, _) = triangle_board(5, 0)
  assert_true(t.symmetry_count(AnySingle) >= 1)
}
