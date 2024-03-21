import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/result.{try}
import gleam/string

pub fn return_if_ok(
  what what: Result(a, b),
  otherwise otherwise: fn() -> Result(a, b),
) -> Result(a, b) {
  bool.guard(when: result.is_ok(what), return: what, otherwise: otherwise)
}

pub fn return_if_error(
  what requirement: Result(a, b),
  otherwise consequence: c,
  callback alternative: fn(a) -> c,
) {
  case requirement {
    Error(_) -> consequence
    Ok(v) -> alternative(v)
  }
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

type Index =
  Int

type Length =
  Int

type DigitIndexLength =
  Dict(Index, Length)

fn get_digit_coordinates_aux(
  digits: List(String),
  digits_dict: DigitIndexLength,
  last_index: Option(Index),
  curr_index: Int,
) {
  case digits {
    [] -> digits_dict
    [hd, ..tl] -> {
      let #(d, i) = case int.parse(hd) {
        Error(_) -> #(digits_dict, None)
        Ok(_) -> {
          let index_to_update = option.unwrap(last_index, or: curr_index)
          let d =
            dict.update(digits_dict, index_to_update, fn(x) {
              case x {
                Some(i) -> i + 1
                None -> 1
              }
            })
          let i = Some(index_to_update)
          #(d, i)
        }
      }
      get_digit_coordinates_aux(tl, d, i, curr_index + 1)
    }
  }
}

pub fn get_digit_coordinates(str: String) -> DigitIndexLength {
  str
  |> string.split("")
  |> get_digit_coordinates_aux(dict.new(), None, 0)
}

pub fn min_pos(a: Int, b: Int) -> Int {
  use <- bool.guard(when: a == -1, return: b)
  use <- bool.guard(when: b == -1, return: a)
  int.min(a, b)
}

pub fn compare_from_list(list: List(a)) -> fn(a, a) -> Order {
  fn(a: a, b: a) {
    let #(ia, ib, _) =
      list.fold_until(list, #(-1, -1, 0), fn(acc, i) {
        let #(ia, ib, index) = acc
        let ia2 = case ia == -1 && i == a {
          True -> index
          False -> ia
        }
        let ib2 = case ib == -1 && i == b {
          True -> index
          False -> ib
        }
        case ia2 != -1 && ib2 != -1 {
          True -> Stop(#(ia2, ib2, index))
          False -> Continue(#(ia2, ib2, index + 1))
        }
      })

    int.compare(ia, ib)
  }
}

pub fn gcd(a: Int, b: Int) -> Int {
  case b {
    0 -> a
    _ -> gcd(b, a % b)
  }
}

pub fn lcm(a: Int, b: Int) -> Int {
  a * b / gcd(a, b)
}
