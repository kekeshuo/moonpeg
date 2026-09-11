///|
test "parse and render row-major holes" {
  let (b, p) = parse_board("#oo\n..#\n")
  assert_eq(b.size(), 4)
  assert_eq(p.count(), 2)
  assert_eq(b.index(1, 0), Some(0))
  assert_eq(b.render(p), "#oo\n..#")
  assert_eq(b.dimensions(), (3, 2))
  let holes = b.holes()
  holes.clear()
  assert_eq(b.size(), 4)
}

///|
test "64 hole occupancy and CRLF" {
  let (b, p) = parse_board(
    "oooooooo\noooooooo\noooooooo\noooooooo\noooooooo\noooooooo\noooooooo\noooooooo",
  )
  assert_eq(b.size(), 64)
  assert_eq(p.count(), 64)
  let (_, q) = parse_board("oo.\r\n")
  assert_eq(q.count(), 2)
}

///|
test "bad boards and foreign occupancy" {
  for s in ["", "###", "o\noo", "o x", "ooooooooo", "o\n\n"] {
    try parse_board(s) catch {
      _ => ()
    } noraise {
      _ => fail("expected invalid board")
    }
  }
  let (b, _) = parse_board("o.")
  try b.validate({ bits: 4UL }) catch {
    e => assert_true(e is InvalidPosition)
  } noraise {
    _ => fail("expected invalid position")
  }
}
