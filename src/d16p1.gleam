import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils
import simplifile

const input_path = "./inputs/d16"

type Contraption =
  List(List(String))

type Direction {
  U
  D
  L
  R
}

type Position =
  #(Int, Int)

type Movement =
  #(Int, Int, Direction)

fn parse_input(file: String) -> Contraption {
  file
  |> string.split("\n")
  |> list.map(string.split(_, ""))
}

fn walk(
  cont: Contraption,
  queue: List(Movement),
  visited: Dict(Movement, Bool),
  counted: Dict(Position, Bool),
  count: Int,
) -> Int {
  let move = fn(from: Movement, dir: Direction) -> Movement {
    let #(y, x, _) = from
    case dir {
      U -> #(y - 1, x, U)
      D -> #(y + 1, x, D)
      L -> #(y, x - 1, L)
      R -> #(y, x + 1, R)
    }
  }

  let get_next_moves = fn(from: Movement, terrain: String, dir: Direction) -> List(
    Movement,
  ) {
    let new_dirs = case terrain, dir {
      ".", U | "/", R | "\\", L | "|", U -> [U]
      ".", D | "/", L | "\\", R | "|", D -> [D]
      ".", L | "/", D | "\\", U | "-", L -> [L]
      ".", R | "/", U | "\\", D | "-", R -> [R]
      "|", L | "|", R -> [U, D]
      "-", U | "-", D -> [R, L]
      _, _ -> []
    }
    list.map(new_dirs, move(from, _))
  }

  case queue {
    [] -> count
    [hd, ..tl] -> {
      let #(y, x, dir) = hd
      case dict.has_key(visited, hd), utils.get_matrix_value(cont, y, x) {
        False, Ok(terrain) -> {
          let new_visited = dict.insert(visited, hd, True)
          let new_moves = get_next_moves(hd, terrain, dir)
          let queue = list.concat([new_moves, tl])
          case dict.get(counted, #(x, y)) {
            Ok(_) -> walk(cont, queue, new_visited, counted, count)
            Error(_) -> {
              let new_counted = dict.insert(counted, #(x, y), True)
              walk(cont, queue, new_visited, new_counted, count + 1)
            }
          }
        }
        _, _ -> walk(cont, tl, visited, counted, count)
      }
    }
  }
}

fn solve(contraption: Contraption) -> Int {
  walk(contraption, [#(0, 0, R)], dict.new(), dict.new(), 0)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
