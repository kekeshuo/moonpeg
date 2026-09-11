///| A jump toggles exactly three bits. Their GF(2) span is a necessary, not sufficient,

///|
/// reachability condition. No claim of solvability follows from membership in this span.
fn Board::jump_basis(self : Board) -> Array[UInt64] {
  let basis = Array::make(64, 0UL)
  for j in self.jumps {
    let mut v = bit(j.from) ^ bit(j.over) ^ bit(j.to)
    for i = 63; i >= 0; i = i - 1 {
      if (v & bit(i)) != 0UL {
        if basis[i] == 0UL {
          basis[i] = v
          break
        } else {
          v = v ^ basis[i]
        }
      }
    }
  }
  basis
}

///|
fn residue(bits : UInt64, basis : Array[UInt64]) -> UInt64 {
  let mut v = bits
  for i = 63; i >= 0; i = i - 1 {
    if (v & bit(i)) != 0UL {
      v = v ^ basis[i]
    }
  }
  v
}

///|
pub fn Board::position_class(
  self : Board,
  p : Position,
) -> UInt64 raise PegError {
  self.validate(p)
  residue(p.bits, self.jump_basis())
}

///|
pub fn Board::class_compatible(
  self : Board,
  start : Position,
  goal : Goal,
) -> Bool raise PegError {
  self.validate(start)
  self.validate_goal(goal)
  let basis = self.jump_basis()
  let sig = residue(start.bits, basis)
  match goal {
    Exact(p) => sig == residue(p.bits, basis)
    AnySingle => {
      for i = 0; i < self.size(); i = i + 1 {
        if sig == residue(bit(i), basis) {
          return true
        }
      }
      false
    }
  }
}
