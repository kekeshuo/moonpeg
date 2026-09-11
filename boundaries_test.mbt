///|
test "only CRLF pairs are accepted and not repeated or bare CR" {
  for text in ["oo.\r", "oo.\r\r\n", "o\r.o"] {
    try parse_board(text) catch {
      e => assert_true(e is InvalidBoard(_))
    } noraise {
      _ => fail("stray CR must not disappear")
    }
  }
  let (b, p) = parse_board("oo.\r\n...\n")
  assert_eq(b.render(p), "oo.\n...")
}

///|
test "high bit destination can be solved and replayed without signed narrowing" {
  let (b, _) = parse_board(
    "........\n........\n........\n........\n........\n........\n........\n........",
  )
  let start : Position = { bits: (1UL << 61) | (1UL << 62) }
  let goal : Goal = Exact({ bits: 1UL << 63 })
  match b.solve(start, goal, 100).outcome {
    Solved(moves) => {
      assert_eq(moves.length(), 1)
      assert_true(b.verify_solution(start, moves, goal))
      assert_true(b.verify_steps(start, goal, b.encode_steps(moves)))
    }
    _ => fail("high-bit jump")
  }
  assert_true(b.class_compatible(start, goal))
}

///|
test "hard transcript bounds and maximum UInt seed remain valid" {
  let (b, p) = parse_board("oo.")
  try b.replay(p, Array::make(64, 0)) catch {
    e => assert_true(e is InvalidTranscript(63))
  } noraise {
    _ => fail("too long")
  }
  let g : Position = { bits: 4UL }
  let generated = b.generate(g, 1, 4294967295U)
  assert_true(b.verify_solution(generated.start, generated.solution, Exact(g)))
}
