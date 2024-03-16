import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d4"

fn get_row_points(row: String) -> Int {
  let assert [_, game] = string.split(row, ":")
  let assert [winning, playing] =
    game
    |> string.split("|")
    |> list.map(fn(s) {
      s
      |> string.split(" ")
      |> list.filter(fn(c) { c != "" })
    })

  list.fold(playing, 0, fn(acc, n) {
    case list.contains(winning, n) {
      True ->
        case acc {
          0 -> 1
          _ -> acc * 2
        }
      False -> acc
    }
  })
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> string.split("\n")
  |> list.map(get_row_points)
  |> list.fold(0, int.add)
  |> int.to_string
  |> io.print
}
