///|
test "disconnected active components cannot merge or disappear" {
  let (b, p) = parse_board("oo.#oo.")
  assert_eq(b.components().length(), 2)
  assert_false(b.component_compatible(p, AnySingle))
  assert_true(b.obstructions(p, AnySingle).contains("jump-components"))
  let g : Goal = Exact({ bits: 36UL })
  assert_true(b.component_compatible(p, g))
}

///|
test "isolated hole is its own jump component" {
  let (b, p) = parse_board("o.o")
  assert_eq(b.components().length(), 1)
  let (c, q) = parse_board("o#o")
  assert_eq(c.components().length(), 2)
  assert_false(c.component_compatible(q, AnySingle))
  assert_true(b.component_compatible(p, Exact(p)))
}

///|
test "all found solutions satisfy obstruction tests" {
  let (b, _) = parse_board(".....")
  for n = 0; n < 32; n = n + 1 {
    let p : Position = { bits: n.to_uint64() }
    match b.solve(p, AnySingle, 10000).outcome {
      Solved(_) => assert_eq(b.obstructions(p, AnySingle), [])
      _ => ()
    }
  }
}
