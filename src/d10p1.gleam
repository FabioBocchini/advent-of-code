import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

const input_path = "./inputs/d10"

type Tile {
  Tile(u: Bool, d: Bool, l: Bool, r: Bool)
}

type Tiles =
  Dict(String, Tile)

type Row =
  List(String)

type Maze =
  List(Row)

type Position =
  #(Int, Int)

const directions = [#(-1, 0), #(1, 0), #(0, -1), #(0, 1)]

const tiles_list = [
  #("S", Tile(u: True, d: True, l: True, r: True)),
  #("7", Tile(u: False, d: True, l: True, r: False)),
  #("F", Tile(u: False, d: True, l: False, r: True)),
  #("|", Tile(u: True, d: True, l: False, r: False)),
  #("L", Tile(u: True, d: False, l: False, r: True)),
  #("J", Tile(u: True, d: False, l: True, r: False)),
  #("-", Tile(u: False, d: False, l: True, r: True)),
]

fn get_val(maze: Maze, position: Position) -> Result(String, Nil) {
  let #(y, x) = position
  use row <- result.try(list.at(maze, y))
  list.at(row, x)
}

fn parse_item(items: List(String), x: Int) -> Option(Int) {
  case items {
    [] -> None
    [hd, ..tl] -> {
      case hd == "S" {
        True -> Some(x)
        False -> parse_item(tl, x + 1)
      }
    }
  }
}

fn parse_row(
  rows: List(String),
  y: Int,
  acc: #(Maze, Option(Position)),
) -> #(Maze, Position) {
  case rows {
    [] -> {
      let assert #(maze, Some(pos)) = acc
      #(list.reverse(maze), pos)
    }
    [hd, ..tl] -> {
      let #(maze, pos) = acc
      let items = string.split(hd, "")
      let new_pos = case pos {
        Some(_) -> pos
        None ->
          case parse_item(items, 0) {
            Some(x) -> Some(#(y, x))
            None -> None
          }
      }
      parse_row(tl, y + 1, #([items, ..maze], new_pos))
    }
  }
}

fn parse_input(file: String) -> #(Maze, Position) {
  file
  |> string.split("\n")
  |> parse_row(0, #([], None))
}

fn move(
  maze: Maze,
  direction: Position,
  visiting: Position,
  from_tile: Tile,
  last_visited: Position,
  tiles: Tiles,
) -> Result(Position, Nil) {
  let #(dy, dx) = direction
  let #(vy, vx) = visiting
  let new_pos = #(dy + vy, dx + vx)

  use <- bool.guard(when: new_pos == last_visited, return: Error(Nil))

  use to_val <- result.try(get_val(maze, new_pos))
  use to_tile <- result.try(dict.get(tiles, to_val))

  let is_possible = case direction {
    #(-1, 0) -> from_tile.u && to_tile.d
    #(1, 0) -> from_tile.d && to_tile.u
    #(0, -1) -> from_tile.l && to_tile.r
    #(0, 1) -> from_tile.r && to_tile.l
    _ -> False
  }

  case is_possible {
    True -> Ok(new_pos)
    False -> Error(Nil)
  }
}

fn get_loop_length(
  maze: Maze,
  starting_position: Position,
  visiting: Position,
  last_visited: Position,
  count: Int,
  tiles: Tiles,
) -> Int {
  use <- bool.guard(
    when: visiting == starting_position && count != 0,
    return: count,
  )

  let assert Ok(next_pos) = {
    use from_val <- result.try(get_val(maze, visiting))
    use tile <- result.try(dict.get(tiles, from_val))
    list.find_map(directions, move(maze, _, visiting, tile, last_visited, tiles))
  }
  get_loop_length(maze, starting_position, next_pos, visiting, count + 1, tiles)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)
  let #(maze, starting_position) = parse_input(file)
  let tiles = dict.from_list(tiles_list)

  maze
  |> get_loop_length(starting_position, starting_position, #(-2, -2), 0, tiles)
  |> int.floor_divide(2)
  |> result.unwrap(0)
  |> int.to_string()
  |> io.print()
}
