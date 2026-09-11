///|
test "solve JSON distinguishes all outcomes" {
  let solved = @json.parse(
    handle(
      (
        #|{"version":1,"command":"solve","board":"oo."}
      ),
    ),
  )
  match solved {
    { "status": String(status), "moves": Array(moves), .. } => {
      assert_eq(status, "solved")
      assert_eq(moves.length(), 1)
    }
    _ => fail("shape")
  }
  let exhausted = @json.parse(
    handle(
      (
        #|{"version":1,"command":"solve","board":"oo.","budget":0}
      ),
    ),
  )
  match exhausted {
    { "status": String("exhausted"), .. } => ()
    _ => fail("budget")
  }
  let dead = @json.parse(
    handle(
      (
        #|{"version":1,"command":"solve","board":"o.o"}
      ),
    ),
  )
  match dead {
    { "status": String("unsolvable"), .. } => ()
    _ => fail("proof")
  }
}

///|
test "strict protocol rejects malformed or ambiguous types" {
  for
    input in [
      "{",
      "null",
      "[]",
      "{}",
      (
        #|{"version":2,"command":"analyze","board":"oo."}
      ),
      (
        #|{"version":1,"command":"analyze","board":"oo.","typo":0}
      ),
      (
        #|{"version":1,"command":"solve","board":"oo.","budget":0.5}
      ),
      (
        #|{"version":1,"command":"solve","board":"oo.","budget":2147483648}
      ),
      (
        #|{"version":1,"command":"generate","board":"oo."}
      ),
      (
        #|{"version":1,"command":"replay","board":"oo.","moves":[-1]}
      ),
      (
        #|{"version":1,"command":"solve","board":"oo.","goal":"..#"}
      ),
    ] {
    match @json.parse(handle(input)) {
      { "status": String("error"), .. } => ()
      _ => fail(input)
    }
  }
}

///|
test "replay and reverse generation return checkable board strings" {
  match
    @json.parse(
      handle(
        (
          #|{"version":1,"command":"replay","board":"oo.","moves":[0]}
        ),
      ),
    ) {
    { "valid_solution": True, "states": Array(states), .. } =>
      assert_eq(states.length(), 2)
    _ => fail("replay")
  }
  match
    @json.parse(
      handle(
        (
          #|{"version":1,"command":"generate","board":"...","goal":"..o","depth":1,"seed":4}
        ),
      ),
    ) {
    { "board": String("oo."), "reached_depth": True, .. } => ()
    _ => fail("generate")
  }
}
