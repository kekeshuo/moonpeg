///|
/// Exhausted is an unknown result, never evidence of impossibility.
pub(all) enum Outcome {
  Solved(Array[Int])
  Unsolvable
  Exhausted
} derive(Debug, Eq)

///|
pub(all) struct SearchReport {
  outcome : Outcome
  visited : Int
} derive(Debug, Eq)

///|
priv struct SearchState {
  mut visited : Int
  budget : Int
  path : Array[Int]
  goal : Goal
}

///|
fn dfs(board : Board, pos : Position, state : SearchState) -> Outcome {
  if state.goal.matches(pos) {
    return Solved(state.path.copy())
  }
  if state.visited >= state.budget {
    return Exhausted
  }
  state.visited = state.visited + 1
  for i = 0; i < board.jumps.length(); i = i + 1 {
    let j = board.jumps[i]
    if enabled(pos.bits, j) {
      state.path.push(i)
      let result = dfs(board, { bits: transition(pos.bits, j) }, state)
      ignore(state.path.pop())
      match result {
        Unsolvable => ()
        _ => return result
      }
    }
  }
  Unsolvable
}

///| Deterministic DFS. Budget counts expanded non-goal nodes, max 1,000,000.

///|
/// A goal at the starting position succeeds even with zero budget.
pub fn Board::solve(
  self : Board,
  start : Position,
  goal : Goal,
  budget : Int,
) -> SearchReport raise PegError {
  self.validate(start)
  self.validate_goal(goal)
  if budget < 0 || budget > 1000000 {
    raise InvalidBudget
  }
  let state = { visited: 0, budget, path: [], goal }
  let outcome = dfs(self, start, state)
  { outcome, visited: state.visited }
}
