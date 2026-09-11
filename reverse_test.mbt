///|
test "every legal jump has a checked inverse on all line occupancies" {
  let (b, _) = parse_board("......")
  for n = 0; n < 64; n = n + 1 {
    let p : Position = { bits: n.to_uint64() }
    for id in b.legal_moves(p) {
      let q = b.play(p, id)
      assert_eq(b.unplay(q, id), p)
      assert_eq(q.count() + 1, p.count())
    }
    for id in b.reverse_moves(p) {
      let q = b.unplay(p, id)
      assert_eq(b.play(q, id), p)
    }
  }
}

///|
test "reverse never overwrites occupied source and rejects invalid ids" {
  let (b, p) = parse_board("o.o")
  for id in [-1, 0, 1, 99] {
    try b.unplay(p, id) catch {
      e => assert_true(e is InvalidMove(_))
    } noraise {
      _ => fail("invalid inverse accepted")
    }
  }
}
