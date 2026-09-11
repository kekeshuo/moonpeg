///| Components connect all holes participating in a jump, not just adjacent grid cells.

///|
/// An occupied component cannot become empty by peg removal; an empty one cannot gain a peg.
pub fn Board::components(self : Board) -> Array[Array[Int]] {
  let labels = Array::make(self.size(), -1)
  let result : Array[Array[Int]] = []
  for root = 0; root < self.size(); root = root + 1 {
    if labels[root] >= 0 {
      continue
    }
    let part = [root]
    labels[root] = result.length()
    let mut cursor = 0
    while cursor < part.length() {
      let here = part[cursor]
      cursor = cursor + 1
      for j in self.jumps {
        if j.from == here || j.over == here || j.to == here {
          for h in [j.from, j.over, j.to] {
            if labels[h] < 0 {
              labels[h] = result.length()
              part.push(h)
            }
          }
        }
      }
    }
    result.push(part)
  }
  result
}

///|
fn component_count(bits : UInt64, holes : Array[Int]) -> Int {
  let mut n = 0
  for h in holes {
    if (bits & bit(h)) != 0UL {
      n = n + 1
    }
  }
  n
}

///|
pub fn Board::component_compatible(
  self : Board,
  start : Position,
  goal : Goal,
) -> Bool raise PegError {
  self.validate(start)
  self.validate_goal(goal)
  let parts = self.components()
  match goal {
    AnySingle => {
      let mut occupied = 0
      for part in parts {
        if component_count(start.bits, part) > 0 {
          occupied = occupied + 1
        }
      }
      occupied == 1
    }
    Exact(p) => {
      for part in parts {
        let a = component_count(start.bits, part)
        let b = component_count(p.bits, part)
        if (a == 0) != (b == 0) || b > a {
          return false
        }
      }
      true
    }
  }
}

///|
/// A list of independently sound obstructions. Empty means unknown, NOT solvable.
pub fn Board::obstructions(
  self : Board,
  start : Position,
  goal : Goal,
) -> Array[String] raise PegError {
  let reasons = []
  if !self.class_compatible(start, goal) {
    reasons.push("position-class")
  }
  if !self.component_compatible(start, goal) {
    reasons.push("jump-components")
  }
  match goal {
    Exact(p) => if p.count() > start.count() { reasons.push("peg-count") }
    AnySingle => ()
  }
  reasons
}
