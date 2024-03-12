import gleam/bool
import gleam/result

pub fn return_if_ok(
  what what: Result(a, b),
  otherwise otherwise: fn() -> Result(a, b),
) -> Result(a, b) {
  bool.guard(when: result.is_ok(what), return: what, otherwise: otherwise)
}
