import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import set.{type Set}
import simplifile

const input_path = "./inputs/d21"

type Position =
  #(Int, Int)

type Map =
  Dict(Position, String)

type Input {
  Input(map: Map, starting_position: Position)
}

const movements = [#(-1, 0), #(1, 0), #(0, -1), #(0, 1)]

fn parse_input(input: String) -> Input {
  let #(map_list, starting_position) =
    input
    |> string.split("\n")
    |> list.index_fold(#([], #(-1, -1)), fn(acc, r, y) {
      string.split(r, "")
      |> list.index_fold(acc, fn(acc2, i, x) {
        let #(acc_map, acc_starting_pos) = acc2
        let new_acc_map = [#(#(y, x), i), ..acc_map]
        let new_acc_starting_pos = case i {
          "S" -> #(y, x)
          _ -> acc_starting_pos
        }
        #(new_acc_map, new_acc_starting_pos)
      })
    })

  let map = dict.from_list(map_list)

  Input(map: map, starting_position: starting_position)
}

fn walk(
  map: Map,
  steps: List(#(Int, Position)),
  max_steps: Int,
  walk_ends: Set(Position),
  visited: Set(#(Int, Position)),
) -> Set(Position) {
  case steps {
    [] -> walk_ends

    [#(steps_taken, position), ..tl] if steps_taken == max_steps -> {
      let new_walk_ends = set.insert(walk_ends, position)
      walk(map, tl, max_steps, new_walk_ends, visited)
    }

    [#(steps_taken, #(y, x)), ..tl] -> {
      let #(new_steps, new_visited) =
        list.filter_map(movements, fn(movement) {
          let #(dy, dx) = movement
          let new_position = #(y + dy, x + dx)
          case dict.get(map, new_position) {
            Ok(".") | Ok("S") -> Ok(new_position)
            _ -> Error(Nil)
          }
        })
        |> list.map(fn(s) { #(steps_taken + 1, s) })
        |> list.fold(#(tl, visited), fn(acc, s) {
          let #(acc_steps, acc_visited) = acc
          case set.contains(acc_visited, s) {
            True -> acc
            False -> #([s, ..acc_steps], set.insert(acc_visited, s))
          }
        })

      walk(map, new_steps, max_steps, walk_ends, new_visited)
    }
  }
}

fn solve(input: Input) -> Int {
  walk(input.map, [#(0, input.starting_position)], 64, set.new(), set.new())
  |> set.size()
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
