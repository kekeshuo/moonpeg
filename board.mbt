///|
/// Errors are stable codes with context. No user input is used as an index before validation.
pub suberror PegError {
  InvalidBoard(String)
  InvalidPosition
} derive(Debug, Eq)

///|
/// A hole coordinate. x and y are zero based.
pub(all) struct Cell {
  x : Int
  y : Int
} derive(Debug, Eq)

///|
/// Board topology is opaque; returned collections are copies.
pub struct Board {
  width : Int
  height : Int
  cells : Array[Cell]
  mask : UInt64
} derive(Debug)

///|
/// An immutable occupancy bitset; indices follow row-major order over holes only.
pub(all) struct Position {
  bits : UInt64
} derive(Debug, Eq, Hash)

///|
fn bit(i : Int) -> UInt64 {
  1UL << i
}

///|
pub fn Board::size(self : Board) -> Int {
  self.cells.length()
}

///|
pub fn Board::dimensions(self : Board) -> (Int, Int) {
  (self.width, self.height)
}

///|
pub fn Board::holes(self : Board) -> Array[Cell] {
  self.cells.copy()
}

///|
pub fn Board::index(self : Board, x : Int, y : Int) -> Int? {
  for i = 0; i < self.cells.length(); i = i + 1 {
    if self.cells[i] == { x, y } {
      return Some(i)
    }
  }
  None
}

///|
pub fn Board::validate(self : Board, pos : Position) -> Unit raise PegError {
  if (pos.bits & self.mask) != pos.bits {
    raise InvalidPosition
  }
}

///|
pub fn Position::count(self : Position) -> Int {
  let mut bits = self.bits
  let mut n = 0
  while bits != 0UL {
    bits = bits & (bits - 1UL)
    n = n + 1
  }
  n
}

///|
/// Rectangular ASCII: o=peg, .=empty hole, #=absent. Optional final LF, CRLF accepted.
pub fn parse_board(text : String) -> (Board, Position) raise PegError {
  if text.length() == 0 || text.length() > 200 {
    raise InvalidBoard("size")
  }
  let rows = text
    .split("\n")
    .map(s => s.to_owned().trim_end(chars="\r").to_owned())
    .collect()
  if rows.length() > 1 && rows[rows.length() - 1] == "" {
    ignore(rows.pop())
  }
  if rows.length() == 0 || rows.length() > 8 {
    raise InvalidBoard("height")
  }
  let w = rows[0].length()
  if w == 0 || w > 8 {
    raise InvalidBoard("width")
  }
  let cells : Array[Cell] = []
  let mut bits = 0UL
  let mut mask = 0UL
  for y = 0; y < rows.length(); y = y + 1 {
    if rows[y].length() != w {
      raise InvalidBoard("ragged")
    }
    for x = 0; x < w; x = x + 1 {
      match rows[y][x] {
        'o' | '.' => {
          let b = bit(cells.length())
          mask = mask | b
          if rows[y][x] == 'o' {
            bits = bits | b
          }
          cells.push({ x, y })
        }
        '#' => ()
        _ => raise InvalidBoard("character")
      }
    }
  }
  if cells.length() == 0 {
    raise InvalidBoard("no holes")
  }
  ({ width: w, height: rows.length(), cells, mask }, { bits, })
}

///|
pub fn Board::render(self : Board, pos : Position) -> String raise PegError {
  self.validate(pos)
  let out = StringBuilder::new()
  for y = 0; y < self.height; y = y + 1 {
    if y > 0 {
      out.write_string("\n")
    }
    for x = 0; x < self.width; x = x + 1 {
      match self.index(x, y) {
        None => out.write_string("#")
        Some(i) =>
          out.write_string(if (pos.bits & bit(i)) == 0UL { "." } else { "o" })
      }
    }
  }
  out.to_string()
}
