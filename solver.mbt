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
  cache_hits : Int
} derive(Debug, Eq)

///|
priv struct SearchState {
  mut visited : Int
  budget : Int
  path : Array[Int]
  goal : Goal
  dead : Map[UInt64, Bool]
  memoize : Bool
  maps : Array[Array[Int]]
  mut cache_hits : Int
}

///|
fn dfs(board : Board, pos : Position, state : SearchState) -> Outcome {
  if state.goal.matches(pos) {
    return Solved(state.path.copy())
  }
  let key = canonical_bits(pos.bits, state.maps)
  if state.memoize && state.dead.contains(key) {
    state.cache_hits = state.cache_hits + 1
    return Unsolvable
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
  if state.memoize {
    state.dead.set(key, true)
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
  memoize? : Bool = true,
  symmetry? : Bool = true,
) -> SearchReport raise PegError {
  self.validate(start)
  self.validate_goal(goal)
  if budget < 0 || budget > 1000000 {
    raise InvalidBudget
  }
  let state = {
    visited: 0,
    budget,
    path: [],
    goal,
    dead: Map([]),
    memoize,
    maps: if symmetry {
      self.symmetries(goal)
    } else {
      []
    },
    cache_hits: 0,
  }
  let outcome = dfs(self, start, state)
  { outcome, visited: state.visited, cache_hits: state.cache_hits }
}
