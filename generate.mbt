///|
/// Generated puzzles always carry a forward solution; target depth is a request, not a guarantee.
pub(all) struct Generated {
  start : Position
  goal : Position
  solution : Array[Int]
  reached_depth : Bool
} derive(Debug, Eq)

///| Seeded inverse walk, not a uniform sampler or a difficulty estimator.

///|
/// Wrapping UInt arithmetic is intentional for the portable deterministic PRNG.
pub fn Board::generate(
  self : Board,
  goal : Position,
  depth : Int,
  seed : UInt,
) -> Generated raise PegError {
  self.validate_goal(Exact(goal))
  if depth < 0 || depth > self.size() - goal.count() {
    raise InvalidBudget
  }
  let mut p = goal
  let reverse_path : Array[Int] = []
  let mut rng = seed
  for step = 0; step < depth; step = step + 1 {
    let choices = self.reverse_moves(p)
    if choices.is_empty() {
      break
    }
    rng = rng * 1664525U + 1013904223U
    let selected = (rng % choices.length().reinterpret_as_uint()).reinterpret_as_int()
    let id = choices[selected]
    p = self.unplay(p, id)
    reverse_path.push(id)
  }
  let solution = reverse_path.rev()
  { start: p, goal, solution, reached_depth: solution.length() == depth }
}
