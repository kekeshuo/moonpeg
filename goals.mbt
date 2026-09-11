///|
/// Exact targets must be nonempty, in-bounds occupancies.
pub(all) enum Goal {
  AnySingle
  Exact(Position)
} derive(Debug, Eq)

///|
pub fn Board::validate_goal(self : Board, goal : Goal) -> Unit raise PegError {
  match goal {
    AnySingle => ()
    Exact(p) =>
      if p.bits == 0UL || (p.bits & self.mask) != p.bits {
        raise InvalidGoal
      }
  }
}

///|
fn Goal::matches(self : Goal, p : Position) -> Bool {
  match self {
    AnySingle => p.count() == 1
    Exact(q) => p == q
  }
}

///|
pub fn Board::is_goal(
  self : Board,
  p : Position,
  goal : Goal,
) -> Bool raise PegError {
  self.validate(p)
  self.validate_goal(goal)
  goal.matches(p)
}

///|
pub fn Board::is_terminal(self : Board, p : Position) -> Bool raise PegError {
  self.legal_moves(p).is_empty()
}

///|
/// Construct an exact singleton goal using public grid coordinates.
pub fn Board::goal_at(self : Board, x : Int, y : Int) -> Goal raise PegError {
  match self.index(x, y) {
    Some(i) => Exact({ bits: bit(i) })
    None => raise InvalidGoal
  }
}
