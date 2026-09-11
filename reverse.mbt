///|
/// The inverse of a forward jump: its destination must hold the only peg of the triple.
fn reverse_enabled(bits : UInt64, j : Jump) -> Bool {
  (bits & bit(j.from)) == 0UL &&
  (bits & bit(j.over)) == 0UL &&
  (bits & bit(j.to)) != 0UL
}

///|
pub fn Board::unplay(
  self : Board,
  pos : Position,
  move_id : Int,
) -> Position raise PegError {
  self.validate(pos)
  if move_id < 0 || move_id >= self.jumps.length() {
    raise InvalidMove(move_id)
  }
  let j = self.jumps[move_id]
  if !reverse_enabled(pos.bits, j) {
    raise InvalidMove(move_id)
  }
  { bits: transition(pos.bits, j) }
}

///|
pub fn Board::reverse_moves(
  self : Board,
  pos : Position,
) -> Array[Int] raise PegError {
  self.validate(pos)
  let ids = []
  for i = 0; i < self.jumps.length(); i = i + 1 {
    if reverse_enabled(pos.bits, self.jumps[i]) {
      ids.push(i)
    }
  }
  ids
}
