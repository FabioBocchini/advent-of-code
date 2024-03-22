import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "./inputs/d9"

fn parse_input(file: String) -> List(List(Int)) {
  file
  |> string.split("\n")
  |> list.map(fn(r) {
    r
    |> string.split(" ")
    |> list.try_map(int.parse)
    |> result.unwrap([])
  })
}

fn get_diffs(row: List(Int), diffs: List(Int)) -> List(Int) {
  case row {
    [] | [_] -> list.reverse(diffs)
    [f, s, ..tl] -> get_diffs([s, ..tl], [s - f, ..diffs])
  }
}

fn is_last_diff(row: List(Int)) -> Bool {
  list.all(row, fn(x) { x == 0 })
}

fn solve_row(row: List(Int), last_values: List(Int)) -> Int {
  let differences = get_diffs(row, [])
  let assert Ok(last) = list.last(row)
  let new_last_values = [last, ..last_values]
  case is_last_diff(differences) {
    True -> list.fold(new_last_values, 0, int.add)
    False -> solve_row(differences, new_last_values)
  }
}

fn solve(rows: List(List(Int)), histories: List(Int)) -> Int {
  case rows {
    [] -> list.fold(histories, 0, int.add)
    [hd, ..tl] -> {
      let new_histories = [solve_row(hd, []), ..histories]
      solve(tl, new_histories)
    }
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve([])
  |> int.to_string()
  |> io.print()
}
