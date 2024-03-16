import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import utils

const input_path = "./inputs/d3"

fn is_symbol(char: String) -> Bool {
  char != "." && char != "" && result.is_error(int.parse(char))
}

fn check_curr_row(row: String, index: Int, length: Int) -> Bool {
  let prev_char = case index == 0 {
    True -> ""
    False -> string.slice(row, index - 1, 1)
  }
  use <- bool.guard(when: is_symbol(prev_char), return: True)

  let next_char = string.slice(row, index + length, 1)
  is_symbol(next_char)
}

fn check_adj_row(row: String, index: Int, length: Int) -> Bool {
  case index == 0 {
    True -> string.slice(row, 0, length + 1)
    False -> string.slice(row, index - 1, length + 2)
  }
  |> string.split("")
  |> list.any(is_symbol)
}

fn solve_row(row: String, prev: String, next: String, sum: Int) -> Int {
  utils.get_digit_coordinates(row)
  |> dict.fold(sum, fn(acc, index, length) {
    let assert Ok(num) =
      row
      |> string.slice(index, length)
      |> int.parse

    case
      check_curr_row(row, index, length)
      || check_adj_row(prev, index, length)
      || check_adj_row(next, index, length)
    {
      True -> acc + num
      False -> acc
    }
  })
}

fn solve(rows: List(String), prev: String, sum: Int) -> Int {
  case rows {
    [] -> sum
    [hd, ..tl] -> {
      let next = result.unwrap(list.first(tl), "")
      let row_value = solve_row(hd, prev, next, sum)
      solve(tl, hd, row_value)
    }
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> string.split("\n")
  |> solve("", 0)
  |> int.to_string
  |> io.println
}
