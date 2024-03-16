import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile
import utils

const input_path = "./inputs/d3p2"

type Gear =
  #(Int, Int)

type GearParts =
  Dict(Gear, List(Int))

fn is_gear(char: String) -> Bool {
  char == "*"
}

fn check_curr_row(
  row: String,
  row_index: Int,
  index: Int,
  length: Int,
) -> List(Gear) {
  let prev_char = case index == 0 {
    True -> ""
    False -> string.slice(row, index - 1, 1)
  }
  let gears = case is_gear(prev_char) {
    True -> [#(row_index, index - 1)]
    False -> []
  }
  let next_char = string.slice(row, index + length, 1)
  case is_gear(next_char) {
    True -> [#(row_index, index + length), ..gears]
    False -> gears
  }
}

fn check_adj_row(
  row: String,
  row_index: Int,
  index: Int,
  length: Int,
) -> List(Gear) {
  case index == 0 {
    True -> " " <> string.slice(row, 0, length + 1)
    False -> string.slice(row, index - 1, length + 2)
  }
  |> string.split("")
  |> list.index_fold([], fn(acc, c, i) {
    case is_gear(c) {
      True -> [#(row_index, index + i - 1), ..acc]
      False -> acc
    }
  })
}

fn solve_row(
  row: String,
  prev: String,
  next: String,
  row_index: Int,
  gears: GearParts,
) -> GearParts {
  utils.get_digit_coordinates(row)
  |> dict.fold(gears, fn(acc, index, length) {
    let assert Ok(num) =
      row
      |> string.slice(index, length)
      |> int.parse

    let new_gears =
      list.concat([
        check_curr_row(row, row_index, index, length),
        check_adj_row(prev, row_index - 1, index, length),
        check_adj_row(next, row_index + 1, index, length),
      ])

    use new_gears, g <- list.fold(new_gears, acc)
    use x <- dict.update(new_gears, g)
    case x {
      Some(i) -> [num, ..i]
      None -> [num]
    }
  })
}

fn solve(
  rows: List(String),
  prev: String,
  row_index: Int,
  gears: GearParts,
) -> Int {
  case rows {
    [] ->
      dict.fold(gears, 0, fn(acc, _, values) {
        case values {
          [f, s] -> acc + f * s
          _ -> acc
        }
      })
    [hd, ..tl] ->
      tl
      |> list.first
      |> result.unwrap("")
      |> solve_row(hd, prev, _, row_index, gears)
      |> solve(tl, hd, row_index + 1, _)
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> string.split("\n")
  |> solve("", 0, dict.new())
  |> int.to_string
  |> io.println
}
