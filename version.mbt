///|
pub fn version() -> String {
  "0.1.0"
}

///|
test "version identifies the API" {
  assert_eq(version(), "0.1.0")
}
