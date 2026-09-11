///|
fn demonstrate() -> Unit raise {
  let (b, start) = @peg.triangle_board(5, 0)
  println("MoonPeg: triangular 15-hole puzzle")
  println(b.render(start))
  let result = b.solve(start, AnySingle, 100000)
  match result.outcome {
    Solved(moves) => {
      assert_true(b.verify_solution(start, moves, AnySingle))
      println(
        "Solved: \{moves.length()} jumps; expanded \{result.visited} nodes",
      )
      let states = b.replay(start, moves)
      println(b.render(states[states.length() - 1]))
    }
    _ => abort("tutorial fixture must solve within the documented budget")
  }
  let goal = b.goal_at(0, 0)
  let end = match goal {
    Exact(p) => p
    _ => abort("exact coordinate goal")
  }
  let generated = b.generate(end, 8, 42U)
  assert_true(b.verify_solution(generated.start, generated.solution, goal))
  let portable = b.encode_steps(generated.solution)
  assert_true(b.verify_steps(generated.start, goal, portable))
  println(
    "Generated: \{generated.start.count()} pegs; verified coordinate certificate",
  )
  let (line, p) = @peg.parse_board("oo.")
  assert_eq(line.solve(p, AnySingle, 0).outcome, Exhausted)
  let (_, dead) = @peg.parse_board("o.o")
  assert_eq(line.solve(dead, AnySingle, 100).outcome, Unsolvable)
  println("Budget exhaustion and proven impossibility remain distinct.")
}

///|
fn main {
  demonstrate() catch {
    _ => abort("tutorial assertion or operation failed")
  }
}
