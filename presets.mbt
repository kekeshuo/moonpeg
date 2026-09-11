///|
/// Triangular coordinates use the axial directions (1,0), (0,1), (1,1) and negatives.
pub(all) enum Lattice {
  Orthogonal
  Triangular
} derive(Debug, Eq)

///|
fn Lattice::directions(self : Lattice) -> Array[(Int, Int)] {
  match self {
    Orthogonal => [(1, 0), (0, 1), (-1, 0), (0, -1)]
    Triangular => [(1, 0), (0, 1), (1, 1), (-1, 0), (0, -1), (-1, -1)]
  }
}

///|
pub fn Board::lattice(self : Board) -> Lattice {
  self.lattice
}

///|
/// Classic 33-hole English cross, with an empty center.
pub fn english_board() -> (Board, Position) raise PegError {
  parse_board("##ooo##\n##ooo##\nooooooo\nooo.ooo\nooooooo\n##ooo##\n##ooo##")
}

///|
/// Triangular preset of side 2..8; vacancy is a row-major hole index.
pub fn triangle_board(
  side : Int,
  vacancy : Int,
) -> (Board, Position) raise PegError {
  if side < 2 || side > 8 || vacancy < 0 || vacancy >= side * (side + 1) / 2 {
    raise InvalidBoard("triangle")
  }
  let out = StringBuilder::new()
  let mut n = 0
  for y = 0; y < side; y = y + 1 {
    if y > 0 {
      out.write_string("\n")
    }
    for x = 0; x < side; x = x + 1 {
      if x > y {
        out.write_string("#")
      } else {
        out.write_string(if n == vacancy { "." } else { "o" })
        n = n + 1
      }
    }
  }
  parse_board(out.to_string(), lattice=Triangular)
}
