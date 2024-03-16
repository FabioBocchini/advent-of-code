import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/result
import utils
import simplifile

const input_path = "./inputs/d1"

fn find_first_digit(chars: List(String)) -> Result(Int, Nil) {
  case chars {
    [hd, ..tl] -> {
      use <- utils.return_if_ok(int.parse(hd))
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
