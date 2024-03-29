import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d14"

fn parse_input(file: String) {
  file
  |> string.split("\n")
  |> list.map(string.split(_, ""))
  |> list.transpose()
}

fn get_positions(
  row: List(String),
  index: Int,
  min_index: Int,
  positions: List(Int),
) -> List(Int) {
  case row {
    [] -> positions
    [hd, ..tl] ->
      case hd {
        "#" -> get_positions(tl, index + 1, index + 1, positions)
        "." -> get_positions(tl, index + 1, min_index, positions)
        "O" ->
          get_positions(tl, index + 1, min_index + 1, [min_index, ..positions])
        _ -> []
      }
  }
}

fn solve(rows: List(List(String))) -> Int {
  let length = {
    let assert [hd, ..] = rows
    list.length(hd)
  }

  use acc, r <- list.fold(rows, 0)
  let res =
    r
    |> get_positions(0, 0, [])
    |> list.fold(0, fn(acc_2, p) { acc_2 + length - p })
  acc + res
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
