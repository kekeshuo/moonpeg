///| D4 coordinate candidates are retained only when both holes AND all directed jumps are preserved.

///|
/// This is conservative on triangular lattices: no unsupported 60-degree symmetry is assumed.
fn Board::symmetries(self : Board, goal : Goal) -> Array[Array[Int]] {
  let maps : Array[Array[Int]] = []
  for t = 0; t < 8; t = t + 1 {
    let permutation : Array[Int] = []
    for c in self.cells {
      let (x, y) = match t {
        0 => (c.x, c.y)
        1 => (self.width - 1 - c.x, c.y)
        2 => (c.x, self.height - 1 - c.y)
        3 => (self.width - 1 - c.x, self.height - 1 - c.y)
        4 => (c.y, c.x)
        5 => (self.height - 1 - c.y, c.x)
        6 => (c.y, self.width - 1 - c.x)
        _ => (self.height - 1 - c.y, self.width - 1 - c.x)
      }
      match self.index(x, y) {
        Some(i) => permutation.push(i)
        None => break
      }
    }
    if permutation.length() != self.size() {
      continue
    }
    let mut valid = true
    for j in self.jumps {
      let transformed : Jump = {
        from: permutation[j.from],
        over: permutation[j.over],
        to: permutation[j.to],
      }
      if !self.jumps.contains(transformed) {
        valid = false
        break
      }
    }
    if !valid {
      continue
    }
    match goal {
      Exact(p) => if transform_bits(p.bits, permutation) != p.bits { continue }
      AnySingle => ()
    }
    if !maps.contains(permutation) {
      maps.push(permutation)
    }
  }
  maps
}

///|
fn transform_bits(bits : UInt64, permutation : Array[Int]) -> UInt64 {
  let mut result = 0UL
  for i = 0; i < permutation.length(); i = i + 1 {
    if (bits & bit(i)) != 0UL {
      result = result | bit(permutation[i])
    }
  }
  result
}

///|
fn canonical_bits(bits : UInt64, maps : Array[Array[Int]]) -> UInt64 {
  let mut best = bits
  for m in maps {
    let v = transform_bits(bits, m)
    if v < best {
      best = v
    }
  }
  best
}

///|
/// Canonicalization is goal-dependent, so a corner goal is never swapped to another corner.
pub fn Board::canonical(
  self : Board,
  p : Position,
  goal : Goal,
) -> Position raise PegError {
  self.validate(p)
  self.validate_goal(goal)
  { bits: canonical_bits(p.bits, self.symmetries(goal)) }
}

///|
pub fn Board::symmetry_count(self : Board, goal : Goal) -> Int raise PegError {
  self.validate_goal(goal)
  self.symmetries(goal).length()
}
