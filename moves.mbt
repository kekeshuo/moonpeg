///|
/// Jump indices refer to holes, not grid offsets.
pub(all) struct Jump {
  from : Int
  over : Int
  to : Int
} derive(Debug, Eq)

///|
fn cell_index(cells : Array[Cell], x : Int, y : Int) -> Int? {
  for i = 0; i < cells.length(); i = i + 1 {
    if cells[i] == { x, y } {
      return Some(i)
    }
  }
  None
}

///|
fn compile_jumps(cells : Array[Cell]) -> Array[Jump] {
  let jumps : Array[Jump] = []
  for i = 0; i < cells.length(); i = i + 1 {
    let c = cells[i]
    for d in [(1, 0), (0, 1), (-1, 0), (0, -1)] {
      match
        (
          cell_index(cells, c.x + d.0, c.y + d.1),
          cell_index(cells, c.x + 2 * d.0, c.y + 2 * d.1),
        ) {
        (Some(over), Some(to)) => jumps.push({ from: i, over, to })
        _ => ()
      }
    }
  }
  jumps
}

///|
pub fn Board::jumps(self : Board) -> Array[Jump] {
  self.jumps.copy()
}

///|
fn enabled(bits : UInt64, j : Jump) -> Bool {
  (bits & bit(j.from)) != 0UL &&
  (bits & bit(j.over)) != 0UL &&
  (bits & bit(j.to)) == 0UL
}

///|
fn transition(bits : UInt64, j : Jump) -> UInt64 {
  bits ^ bit(j.from) ^ bit(j.over) ^ bit(j.to)
}

///|
/// Invalid moves never modify their input position.
pub fn Board::play(
  self : Board,
  pos : Position,
  move_id : Int,
) -> Position raise PegError {
  self.validate(pos)
  if move_id < 0 || move_id >= self.jumps.length() {
    raise InvalidMove(move_id)
  }
  let j = self.jumps[move_id]
  if !enabled(pos.bits, j) {
    raise InvalidMove(move_id)
  }
  { bits: transition(pos.bits, j) }
}

///|
pub fn Board::legal_moves(
  self : Board,
  pos : Position,
) -> Array[Int] raise PegError {
  self.validate(pos)
  let moves = []
  for i = 0; i < self.jumps.length(); i = i + 1 {
    if enabled(pos.bits, self.jumps[i]) {
      moves.push(i)
    }
  }
  moves
}
