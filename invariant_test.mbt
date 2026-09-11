///|
test "GF2 residue unchanged by all legal moves on 512 occupancies" {
  let (b, _) = parse_board("...\n...\n...")
  for n = 0; n < 512; n = n + 1 {
    let p : Position = { bits: n.to_uint64() }
    let sig = b.position_class(p)
    for id in b.legal_moves(p) {
      assert_eq(b.position_class(b.play(p, id)), sig)
    }
  }
}

///|
test "incompatible targets are ruled out but compatibility is not a solution" {
  let (b, p) = parse_board("oo.")
  assert_true(b.class_compatible(p, b.goal_at(2, 0)))
  assert_false(b.class_compatible(p, b.goal_at(0, 0)))
  let (c, q) = parse_board("ooo")
  assert_false(c.class_compatible(q, AnySingle))
  let (t, r) = triangle_board(5, 0)
  assert_true(t.class_compatible(r, AnySingle))
}

///|
test "GF2 handles high bit without signed overflow" {
  let (b, p) = parse_board(
    "oooooooo\noooooooo\noooooooo\noooooooo\noooooooo\noooooooo\noooooooo\nooooooo.",
  )
  for id in b.legal_moves(p) {
    assert_eq(b.position_class(p), b.position_class(b.play(p, id)))
  }
}
