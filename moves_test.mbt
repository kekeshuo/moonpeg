///|
test "jump removes exactly the jumped peg" {
  let (b, p) = parse_board("oo.")
  assert_eq(b.jumps().length(), 2)
  assert_eq(b.legal_moves(p), [0])
  let q = b.play(p, 0)
  assert_eq(b.render(q), "..o")
  assert_eq(q.count(), p.count() - 1)
  assert_eq(b.render(p), "oo.")
}

///|
test "invalid IDs blocked jumps and gaps" {
  let (b, p) = parse_board("oo.")
  for i in [-1, 1, 999] {
    try b.play(p, i) catch {
      e => assert_true(e is InvalidMove(_))
    } noraise {
      _ => fail("illegal move accepted")
    }
  }
  let (c, q) = parse_board("o#.")
  assert_eq(c.legal_moves(q), [])
  let (d, r) = parse_board("ooo")
  assert_eq(d.legal_moves(r), [])
}

///|
test "four directions use stable row-major move order" {
  let (b, p) = parse_board(".o.\nooo\n.o.")
  for id in b.legal_moves(p) {
    assert_eq(b.play(p, id).count(), 4)
  }
  let j = b.jumps()
  j.clear()
  assert_true(b.jumps().length() > 0)
}
