///|
/// Includes initial position. Error index is zero based; input is not mutated.
pub fn Board::replay(
  self : Board,
  start : Position,
  moves : Array[Int],
) -> Array[Position] raise PegError {
  self.validate(start)
  if moves.length() > 63 {
    raise InvalidTranscript(63)
  }
  let states = [start]
  let mut p = start
  for i = 0; i < moves.length(); i = i + 1 {
    p = self.play(p, moves[i]) catch { _ => raise InvalidTranscript(i) }
    states.push(p)
  }
  states
}

///|
/// The whole transcript must be legal and reach the requested goal.
pub fn Board::verify_solution(
  self : Board,
  start : Position,
  moves : Array[Int],
  goal : Goal,
) -> Bool raise PegError {
  self.validate_goal(goal)
  let states = self.replay(start, moves)
  goal.matches(states[states.length() - 1])
}
