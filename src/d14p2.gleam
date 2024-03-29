import gleam/dict.{type Dict}
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

fn get_steady_positions(
  row: List(String),
  index: Int,
  positions: List(Int),
) -> List(Int) {
  case row {
    [] -> positions
    [hd, ..tl] ->
      case hd {
        "O" -> get_steady_positions(tl, index + 1, [index, ..positions])
        _ -> get_steady_positions(tl, index + 1, positions)
      }
  }
}

fn get_new_row(
  row: List(String),
  positions: List(Int),
  index: Int,
  new_row: List(String),
) -> List(String) {
  case row {
    [] -> new_row
    [hd, ..tl] ->
      case hd, positions {
        "#", _ -> get_new_row(tl, positions, index + 1, ["#", ..new_row])
        _, [hp, ..rp] if hp == index ->
          get_new_row(tl, rp, index + 1, ["O", ..new_row])
        _, _ -> get_new_row(tl, positions, index + 1, [".", ..new_row])
      }
  }
}

fn get_next_cycle(rows: List(List(String))) -> List(List(String)) {
  list.range(1, 4)
  |> list.fold(rows, fn(acc, _) {
    acc
    |> list.transpose()
    |> list.map(fn(r) {
      r
      |> get_positions(0, 0, [])
      |> list.reverse()
      |> get_new_row(r, _, 0, [])
    })
  })
}

fn cycle(
  rows: List(List(String)),
  index: Int,
  memo: Dict(List(List(String)), Int),
) -> List(List(String)) {
  case dict.get(memo, rows) {
    Ok(i) -> {
      case { 1_000_000_000 - index } % { index - i } == 0 {
        True -> rows
        False -> {
          let new_rows = get_next_cycle(rows)
          cycle(new_rows, index + 1, memo)
        }
      }
    }
    Error(_) -> {
      let new_memo = dict.insert(memo, rows, index)
      let new_rows = get_next_cycle(rows)
      cycle(new_rows, index + 1, new_memo)
    }
  }
}

fn solve(rows: List(List(String))) -> Int {
  let length = {
    let assert [hd, ..] = rows
    list.length(hd)
  }

  rows
  |> cycle(0, dict.new())
  |> list.transpose()
  |> list.fold(0, fn(acc, r) {
    let res =
      r
      |> get_steady_positions(0, [])
      |> list.fold(0, fn(acc_2, p) { acc_2 + length - p })
    acc + res
  })
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
