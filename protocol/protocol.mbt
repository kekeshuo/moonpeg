///|
priv suberror RequestError {
  BadRequest(String)
}

///|
fn fields(
  value : Json,
  allowed : Array[String],
) -> Map[String, Json] raise RequestError {
  let obj = match value {
    Object(obj) => obj
    _ => raise BadRequest("object required")
  }
  for key, _ in obj {
    if !allowed.contains(key) {
      raise BadRequest("unknown field: " + key)
    }
  }
  obj
}

///|
fn string_field(
  obj : Map[String, Json],
  key : String,
) -> String raise RequestError {
  match obj.get(key) {
    Some(String(s)) => s
    _ => raise BadRequest("string required: " + key)
  }
}

///|
fn integer(
  obj : Map[String, Json],
  key : String,
  fallback : Int,
) -> Int raise RequestError {
  match obj.get(key) {
    None => fallback
    Some(value) => exact_int(value, key)
  }
}

///|
fn certificate(b : @peg.Board, moves : Array[Int]) -> Json raise @peg.PegError {
  b
  .encode_steps(moves)
  .map(s => [[s.from.x, s.from.y], [s.to.x, s.to.y]])
  .to_json()
}

///|
fn report(b : @peg.Board, r : @peg.SearchReport) -> Json raise @peg.PegError {
  let data : Map[String, Json] = Map([
    ("visited", r.visited.to_json()),
    ("cache_hits", r.cache_hits.to_json()),
  ])
  match r.outcome {
    Solved(moves) => {
      data.set("status", "solved".to_json())
      data.set("moves", moves.to_json())
      data.set("steps", certificate(b, moves))
    }
    Unsolvable => data.set("status", "unsolvable".to_json())
    Exhausted => data.set("status", "exhausted".to_json())
  }
  Json::object(data)
}

///|
fn execute(value : Json) -> Json raise {
  let common = ["version", "command", "board", "lattice", "goal"]
  let obj = match value {
    Object(m) => m
    _ => raise BadRequest("object required")
  }
  if integer(obj, "version", -1) != 1 {
    raise BadRequest("version must be 1")
  }
  let command = string_field(obj, "command")
  let extra = match command {
    "analyze" => []
    "solve" | "hints" => ["budget"]
    "replay" => ["moves"]
    "generate" => ["depth", "seed"]
    _ => raise BadRequest("unknown command")
  }
  ignore(fields(value, common + extra))
  let lattice : @peg.Lattice = match obj.get("lattice") {
    None | Some(String("orthogonal")) => Orthogonal
    Some(String("triangular")) => Triangular
    _ => raise BadRequest("unknown lattice")
  }
  let (b, start) = @peg.parse_board(string_field(obj, "board"), lattice~)
  let goal : @peg.Goal = match obj.get("goal") {
    None | Some(String("any")) => AnySingle
    Some(String(text)) => {
      let (target_board, p) = @peg.parse_board(text, lattice~)
      if target_board.dimensions() != b.dimensions() ||
        target_board.holes() != b.holes() {
        raise BadRequest("goal topology differs")
      }
      Exact(p)
    }
    _ => raise BadRequest("goal must be any or an ASCII board")
  }
  // Validate goals for every command, including replay and analysis.
  ignore(b.is_goal(start, goal))
  match command {
    "solve" => report(b, b.solve(start, goal, integer(obj, "budget", 100000)))
    "hints" => {
      let hints = b.hints(start, goal, integer(obj, "budget", 100000))
      {
        "status": "ok",
        "hints": hints
        .map(h => { "move": h.move_id.to_json(), "result": report(b, h.report) })
        .to_json(),
      }
    }
    "analyze" =>
      {
        "status": "ok",
        "holes": b.size().to_json(),
        "pegs": start.count().to_json(),
        "legal_moves": b.legal_moves(start).to_json(),
        "jumps": b.jumps().map(j => [j.from, j.over, j.to]).to_json(),
        "components": b.components().to_json(),
        "obstructions": b.obstructions(start, goal).to_json(),
        "goal_reached": b.is_goal(start, goal).to_json(),
        "terminal": b.is_terminal(start).to_json(),
      }
    "replay" => {
      let moves : Array[Int] = match obj.get("moves") {
        Some(Array(items)) => {
          if items.length() > 63 {
            raise BadRequest("at most 63 moves")
          }
          items.map(v => exact_int(v, "moves"))
        }
        Some(_) => raise BadRequest("moves must be integer array")
        None => raise BadRequest("moves required")
      }
      let states = b.replay(start, moves)
      {
        "status": "ok",
        "valid_solution": b.verify_solution(start, moves, goal).to_json(),
        "states": states.map(p => b.render(p)).to_json(),
        "steps": certificate(b, moves),
      }
    }
    "generate" => {
      let target = match goal {
        Exact(p) => p
        _ => raise BadRequest("generate requires exact goal")
      }
      let seed = integer(obj, "seed", 1)
      if seed < 0 {
        raise BadRequest("seed must be nonnegative Int32")
      }
      let generated = b.generate(
        target,
        integer(obj, "depth", 0),
        seed.reinterpret_as_uint(),
      )
      {
        "status": "ok",
        "board": b.render(generated.start).to_json(),
        "goal": b.render(generated.goal).to_json(),
        "moves": generated.solution.to_json(),
        "steps": certificate(b, generated.solution),
        "reached_depth": generated.reached_depth.to_json(),
      }
    }
    _ => raise BadRequest("unknown command")
  }
}

///|
/// Pure bounded JSON v1 transport; no IO, credentials, or dynamic evaluation.
/// Error messages contain stable codes rather than compiler exception strings.
pub fn handle(input : String) -> String {
  let result : Json = try {
    if input.length() > 16384 {
      raise BadRequest("request too large")
    }
    check_nesting(input)
    let value = @json.parse(input) catch {
      _ => raise BadRequest("invalid JSON")
    }
    execute(value)
  } catch {
    BadRequest(message) =>
      { "status": "error", "code": "request", "message": message.to_json() }
    @peg.InvalidBoard(reason) =>
      { "status": "error", "code": "board", "message": reason.to_json() }
    @peg.InvalidPosition => { "status": "error", "code": "position" }
    @peg.InvalidGoal => { "status": "error", "code": "goal" }
    @peg.InvalidBudget => { "status": "error", "code": "budget" }
    @peg.InvalidTranscript(step) =>
      { "status": "error", "code": "transcript", "step": step.to_json() }
    @peg.InvalidMove(id) =>
      { "status": "error", "code": "move", "move": id.to_json() }
    _ => { "status": "error", "code": "internal" }
  }
  result.stringify()
}

///|
/// Pre-scan outside JSON strings before invoking the core parser's default limit.
/// This keeps the resource bound independent of version-specific optional labels.
fn check_nesting(input : String) -> Unit raise RequestError {
  let mut depth = 0
  let mut quoted = false
  let mut escaped = false
  for c in input {
    if quoted {
      if escaped {
        escaped = false
      } else if c == '\\' {
        escaped = true
      } else if c == '"' {
        quoted = false
      }
    } else if c == '"' {
      quoted = true
    } else if c == '[' || c == '{' {
      depth = depth + 1
      if depth > 16 {
        raise BadRequest("JSON nesting exceeds 16")
      }
    } else if c == ']' || c == '}' {
      depth = depth - 1
    }
  }
}

///|
fn exact_int(value : Json, key : String) -> Int raise RequestError {
  match value {
    Number(n, ..) => {
      if n < -2147483648.0 || n > 2147483647.0 || n != n {
        raise BadRequest("integer range: " + key)
      }
      let i = n.to_int()
      if i.to_double() != n {
        raise BadRequest("integer required: " + key)
      }
      i
    }
    _ => raise BadRequest("integer required: " + key)
  }
}
