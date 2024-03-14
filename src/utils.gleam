import gleam/bool
import gleam/list
import gleam/result.{try}
import gleam/string

pub fn return_if_ok(
  what what: Result(a, b),
  otherwise otherwise: fn() -> Result(a, b),
) -> Result(a, b) {
  bool.guard(when: result.is_ok(what), return: what, otherwise: otherwise)
}

pub fn get_substring_index(
  string str: String,
  substring sub: String,
) -> Result(Int, Nil) {
  case string.contains(does: str, contain: sub) {
    False -> Error(Nil)
    True -> {
      use split_str <- try(
        str
        |> string.split(sub)
        |> list.first,
      )
      Ok(string.length(split_str))
    }
  }
}
