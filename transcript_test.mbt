///|
test "coordinate certificates roundtrip every topology jump" {
  let (b, _) = triangle_board(5, 0)
  for id = 0; id < b.jumps().length(); id = id + 1 {
    assert_eq(b.decode_steps(b.encode_steps([id])), [id])
  }
  let (line, start) = parse_board("oo.")
  let steps = line.encode_steps([0])
  assert_eq(steps, [{ from: { x: 0, y: 0 }, to: { x: 2, y: 0 } }])
  assert_true(line.verify_steps(start, AnySingle, steps))
}

///|
test "coordinates reject non-jumps and transcripts still check occupancy" {
  let (b, p) = parse_board("oo.")
  try b.decode_steps([{ from: { x: 0, y: 0 }, to: { x: 1, y: 0 } }]) catch {
    e => assert_true(e is InvalidTranscript(0))
  } noraise {
    _ => fail("not a jump")
  }
  try
    b.verify_steps(p, AnySingle, [{ from: { x: 2, y: 0 }, to: { x: 0, y: 0 } }])
  catch {
    e => assert_true(e is InvalidTranscript(0))
  } noraise {
    _ => fail("empty source")
  }
  try b.encode_steps([-1]) catch {
    e => assert_true(e is InvalidTranscript(0))
  } noraise {
    _ => fail("negative id")
  }
}
