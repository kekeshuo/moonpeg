///|
test "English board compiles 76 directed jumps" {
  let (b, p) = english_board()
  assert_eq(b.size(), 33)
  assert_eq(p.count(), 32)
  assert_eq(b.jumps().length(), 76)
  assert_eq(b.legal_moves(p).length(), 4)
  assert_eq(b.lattice(), Orthogonal)
}

///|
test "triangle lattice has 36 jumps and includes diagonal axes" {
  let (b, p) = triangle_board(5, 0)
  assert_eq(b.size(), 15)
  assert_eq(p.count(), 14)
  assert_eq(b.jumps().length(), 36)
  assert_eq(b.legal_moves(p).length(), 2)
  assert_eq(b.lattice(), Triangular)
  for id in b.legal_moves(p) {
    assert_eq(b.unplay(b.play(p, id), id), p)
  }
}

///|
test "triangle bounds reject invalid geometry" {
  for args in [(1, 0), (9, 0), (5, 15), (5, -1)] {
    try triangle_board(args.0, args.1) catch {
      _ => ()
    } noraise {
      _ => fail("invalid triangle")
    }
  }
}
