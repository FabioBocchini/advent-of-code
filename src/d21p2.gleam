import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/queue.{type Queue}
import gleam/string
import simplifile

const input_path = "./inputs/d21"

type Position =
  #(Int, Int)

type Map =
  Dict(Position, String)

type Input {
  Input(map: Map, starting_position: Position, dimension: Int)
}

const movements = [#(-1, 0), #(1, 0), #(0, -1), #(0, 1)]

fn parse_input(input: String) -> Input {
  let rows =
    input
    |> string.split("\n")

  let #(map_list, starting_position) =
    rows
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

  let dimension = list.length(rows)

  Input(map: map, starting_position: starting_position, dimension: dimension)
}

fn walk(
  map: Map,
  steps: Queue(#(Position, Int)),
  visited: Dict(Position, Int),
  square_count: #(Int, Int, Int, Int),
  dist_to_border: Int,
) -> #(Int, Int, Int, Int) {
  case queue.pop_front(steps) {
    Error(_) -> square_count
    Ok(#(#(position, distance), tl)) -> {
      case dict.get(visited, position) {
        Ok(_) -> walk(map, tl, visited, square_count, dist_to_border)
        _ -> {
          let #(y, x) = position
          let #(ec, oc, ef, of) = square_count
          let new_visited = dict.insert(visited, position, distance)

          let new_steps =
            list.fold(movements, tl, fn(acc, m) {
              let #(dy, dx) = m
              let new_position = #(y + dy, x + dx)

              case dict.get(map, new_position) {
                Ok(".") | Ok("S") ->
                  queue.push_back(acc, #(new_position, distance + 1))
                _ -> acc
              }
            })

          let new_square_count = case distance % 2, distance > dist_to_border {
            0, True -> #(ec + 1, oc, ef + 1, of)
            1, True -> #(ec, oc + 1, ef, of + 1)
            0, False -> #(ec, oc, ef + 1, of)
            1, False -> #(ec, oc, ef, of + 1)
            _, _ -> square_count
          }

          walk(map, new_steps, new_visited, new_square_count, dist_to_border)
        }
      }
    }
  }
}

fn solve(input: Input, max_step: Int) -> Int {
  // https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21

  let dist_to_border = { input.dimension } / 2

  let #(even_corners, odd_corners, even_full, odd_full) =
    walk(
      input.map,
      queue.from_list([#(input.starting_position, 0)]),
      dict.new(),
      #(0, 0, 0, 0),
      dist_to_border,
    )

  let n = { max_step - dist_to_border } / input.dimension

  let of_count = { n + 1 } * { n + 1 } * odd_full
  let ef_count = n * n * even_full
  let oc_count = { n + 1 } * odd_corners
  let ec_count = n * even_corners

  // - n at the end because for each increase of 131 steps (each square) it adds an error of 1. 
  of_count + ef_count - oc_count + ec_count - n
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve(26_501_365)
  |> int.to_string()
  |> io.print()
}
