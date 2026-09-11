///|
test "replay includes initial and final state and checks goal" {
  let (b, p) = parse_board("oo.")
  let path = b.replay(p, [0])
  assert_eq(path.length(), 2)
  assert_eq(path[0], p)
  assert_true(b.verify_solution(p, [0], AnySingle))
  assert_false(b.verify_solution(p, [], AnySingle))
  assert_false(b.verify_solution(p, [0], b.goal_at(0, 0)))
}

///|
test "tampered transcripts report zero based failing step" {
  let (b, p) = parse_board("oo.")
  try b.replay(p, [0, 0]) catch {
    e => assert_true(e is InvalidTranscript(1))
  } noraise {
    _ => fail("tamper accepted")
  }
  try b.replay(p, [999]) catch {
    e => assert_true(e is InvalidTranscript(0))
  } noraise {
    _ => fail("bad id accepted")
  }
  assert_eq(b.render(p), "oo.")
}
