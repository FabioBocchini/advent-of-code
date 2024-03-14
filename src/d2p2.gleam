import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import simplifile

const input_path = "./inputs/d2p2"

fn calculate_minimum_cubes(
  round: List(String),
  min_cubes: Dict(String, Int),
) -> Dict(String, Int) {
  case round {
    [] -> min_cubes
    [hd, ..tl] -> {
      let assert [n, c] =
        hd
        |> string.trim()
        |> string.split(" ")

      let assert Ok(number) = int.parse(n)

      let new_min_cubes =
        dict.update(min_cubes, c, fn(current_min) {
          case current_min {
            option.Some(v) -> int.max(v, number)
            option.None -> number
          }
        })

      calculate_minimum_cubes(tl, new_min_cubes)
    }
  }
}

fn get_power(game_str: String) -> Int {
  let assert [_, game] =
    game_str
    |> string.split(":")

  game
  |> string.split(";")
  |> list.map(string.split(_, ","))
  |> list.flatten
  |> calculate_minimum_cubes(dict.new())
  |> dict.fold(1, fn(acc, _, n) { acc * n })
}

pub fn main() {
  let assert Ok(file) = simplifile.read(from: input_path)

  file
  |> string.split("\n")
  |> list.map(get_power)
  |> list.fold(0, int.add)
  |> int.to_string
  |> io.print
}
