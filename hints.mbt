///|
/// Each legal opening is classified independently under its share of one total node budget.
pub(all) struct Hint {
  move_id : Int
  report : SearchReport
} derive(Debug, Eq)

///| A solution in each report is a complete certificate from the original start,

///|
/// including the opening move. Later openings receive only unspent budget.
pub fn Board::hints(
  self : Board,
  start : Position,
  goal : Goal,
  budget : Int,
) -> Array[Hint] raise PegError {
  self.validate(start)
  self.validate_goal(goal)
  if budget < 0 || budget > 1000000 {
    raise InvalidBudget
  }
  let ids = self.legal_moves(start)
  let result = []
  let mut remaining = budget
  for id in ids {
    let next = self.play(start, id)
    let r = self.solve(next, goal, remaining)
    remaining = remaining - r.visited
    let outcome = match r.outcome {
      Solved(path) => {
        let full = [id]
        for m in path {
          full.push(m)
        }
        Solved(full)
      }
      other => other
    }
    result.push({
      move_id: id,
      report: { outcome, visited: r.visited, cache_hits: r.cache_hits },
    })
  }
  result
}
