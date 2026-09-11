///|
/// Portable move coordinates, independent of internal move numbering.
pub(all) struct Step {
  from : Cell
  to : Cell
} derive(Debug, Eq)

///|
/// Convert only valid directed board jumps. Occupancy is checked during replay.
pub fn Board::encode_steps(
  self : Board,
  moves : Array[Int],
) -> Array[Step] raise PegError {
  if moves.length() > 63 {
    raise InvalidTranscript(63)
  }
  let out : Array[Step] = []
  for i = 0; i < moves.length(); i = i + 1 {
    let id = moves[i]
    if id < 0 || id >= self.jumps.length() {
      raise InvalidTranscript(i)
    }
    let jump = self.jumps[id]
    out.push({ from: self.cells[jump.from], to: self.cells[jump.to] })
  }
  out
}

///|
pub fn Board::decode_steps(
  self : Board,
  steps : Array[Step],
) -> Array[Int] raise PegError {
  if steps.length() > 63 {
    raise InvalidTranscript(63)
  }
  let out : Array[Int] = []
  for i = 0; i < steps.length(); i = i + 1 {
    let step = steps[i]
    let mut found : Int? = None
    for id = 0; id < self.jumps.length(); id = id + 1 {
      let jump = self.jumps[id]
      if self.cells[jump.from] == step.from && self.cells[jump.to] == step.to {
        found = Some(id)
      }
    }
    match found {
      Some(id) => out.push(id)
      None => raise InvalidTranscript(i)
    }
  }
  out
}

///|
pub fn Board::verify_steps(
  self : Board,
  start : Position,
  goal : Goal,
  steps : Array[Step],
) -> Bool raise PegError {
  self.verify_solution(start, self.decode_steps(steps), goal)
}
