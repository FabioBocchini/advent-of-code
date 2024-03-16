import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "./inputs/d2"

fn get_max_cubes_from_input_hd(hd: String) -> Dict(String, Int) {
  let get_max_cubes_tuple_from_string = fn(str: String) -> #(String, Int) {
    let assert [n, c] =
      str
      |> string.trim()
      |> string.split(" ")

    let assert Ok(number) = int.parse(n)
    #(c, number)
  }

  hd
  |> string.split(on: ";")
  |> list.map(get_max_cubes_tuple_from_string)
  |> dict.from_list
}

fn is_game_possible(game_str: String, max_cubes: Dict(String, Int)) -> Bool {
  let is_hand_possible = fn(hand_str: String) -> Bool {
    case
      hand_str
      |> string.trim
      |> string.split(on: " ")
    {
      [n, c] -> {
        let max = {
          max_cubes
          |> dict.get(c)
          |> result.unwrap(-1)
        }
        let extracted = {
          n
          |> int.parse()
          |> result.unwrap(0)
        }
        max >= extracted
      }
      [] | [_] | [_, _, ..] -> False
    }
  }

  let is_round_possible = fn(round_str: String) -> Bool {
    round_str
    |> string.trim()
    |> string.split(",")
    |> list.all(is_hand_possible)
  }

  game_str
  |> string.split(":")
  |> list.at(1)
  |> result.unwrap("")
  |> string.split(";")
  |> list.all(is_round_possible)
}

fn get_game_id(game_str: String) -> Int {
  game_str
  |> string.split(":")
  |> list.first()
  |> result.unwrap("")
  |> string.split(" ")
  |> list.at(1)
  |> result.try(int.parse)
  |> result.unwrap(0)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(from: input_path)

  let max_cubes = get_max_cubes_from_input_hd("12 red; 13 green; 14 blue")

  file
  |> string.split(on: "\n")
  |> list.filter(is_game_possible(_, max_cubes))
  |> list.map(get_game_id)
  |> list.fold(0, int.add)
  |> int.to_string
  |> io.print
}
