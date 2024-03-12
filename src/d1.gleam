import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/result
import utils
import simplifile

const input_path = "./inputs/d1"

const string_digits = [
  "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
]

fn find_starting_string_digit_aux(
  row: String,
  remaining_string_digits: List(String),
  index: Int,
) -> Result(Int, Nil) {
  case remaining_string_digits {
    [hd, ..tl] -> {
      use <- bool.guard(when: string.starts_with(row, hd), return: Ok(index))
      find_starting_string_digit_aux(row, tl, index + 1)
    }
    [] -> Error(Nil)
  }
}

fn find_starting_string_digit(chars: List(String)) -> Result(Int, Nil) {
  chars
  |> string.join("")
  |> find_starting_string_digit_aux(string_digits, 0)
}

fn find_first_digit(chars: List(String)) -> Result(Int, Nil) {
  case chars {
    [hd, ..tl] -> {
      use <- utils.return_if_ok(int.parse(hd))
      use <- utils.return_if_ok(find_starting_string_digit(chars))
      find_first_digit(tl)
    }
    [] -> Error(Nil)
  }
}

fn find_last_digit_aux(
  rev_chars: List(String),
  last_visited: List(String),
) -> Result(Int, Nil) {
  case rev_chars {
    [hd, ..tl] -> {
      use <- utils.return_if_ok(int.parse(hd))
      let visited = [hd, ..last_visited]
      use <- utils.return_if_ok(find_starting_string_digit(visited))
      find_last_digit_aux(tl, visited)
    }
    [] -> Error(Nil)
  }
}

fn find_last_digit(chars: List(String)) -> Result(Int, Nil) {
  chars
  |> list.reverse
  |> find_last_digit_aux([])
}

fn get_row_value(row: String) -> Int {
  let chars = string.split(row, on: "")
  let v = {
    use f <- result.try(find_first_digit(chars))
    use l <- result.try(find_last_digit(chars))
    Ok(f * 10 + l)
  }
  result.unwrap(v, 0)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(from: input_path)
  file
  |> string.split(on: "\n")
  |> list.map(get_row_value)
  |> list.fold(0, int.add)
  |> int.to_string
  |> io.print
}
