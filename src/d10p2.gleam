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

fn parse_item(items: Row, x: Int) -> Option(Int) {
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

fn get_loop(
  maze: Maze,
  starting_position: Position,
  visiting: Position,
  last_visited: Position,
  loop: List(Position),
  tiles: Tiles,
) -> List(Position) {
  use <- bool.guard(
    when: visiting == starting_position && loop != [],
    return: loop,
  )

  let assert Ok(next_pos) = {
    use from_val <- result.try(get_val(maze, visiting))
    use tile <- result.try(dict.get(tiles, from_val))
    list.find_map(directions, move(maze, _, visiting, tile, last_visited, tiles))
  }
  get_loop(
    maze,
    starting_position,
    next_pos,
    visiting,
    [visiting, ..loop],
    tiles,
  )
}

fn substitute_s(loop: List(Position)) -> String {
  let assert [#(yf, xf), ..] = loop
  let assert [_, #(yl, xl), ..] = list.reverse(loop)

  case yf - yl, xf - xl {
    -1, -1 -> "7"
    -1, 1 -> "F"
    -2, 0 | 2, 0 -> "|"
    1, -1 -> "J"
    1, 1 -> "L"
    0, -2 | 0, 2 -> "-"
    _, _ -> ""
  }
}

fn ray(
  row: Row,
  y: Int,
  x: Int,
  loop: List(Position),
  last_tile: Option(String),
  is_inside: Bool,
  streak: Int,
  count: Int,
  tiles: Tiles,
) -> Int {
  case row {
    [] -> count - streak
    [hd, ..tl] ->
      case list.contains(loop, #(y, x)), hd, is_inside {
        True, "|", _ ->
          ray(tl, y, x + 1, loop, None, !is_inside, 0, count, tiles)
        True, "-", _ ->
          ray(tl, y, x + 1, loop, last_tile, is_inside, 0, count, tiles)
        True, "S", _ -> {
          let s = substitute_s(loop)
          ray([s, ..tl], y, x, loop, last_tile, is_inside, 0, count, tiles)
        }
        True, _, _ ->
          case last_tile {
            None ->
              ray(tl, y, x + 1, loop, Some(hd), is_inside, 0, count, tiles)
            Some(ltv) -> {
              let assert Ok(ltt) = dict.get(tiles, ltv)
              let assert Ok(ctt) = dict.get(tiles, hd)
              case ltt.u && ctt.d || ltt.d && ctt.u {
                True ->
                  ray(tl, y, x + 1, loop, None, !is_inside, 0, count, tiles)
                False ->
                  ray(tl, y, x + 1, loop, None, is_inside, 0, count, tiles)
              }
            }
          }
        False, _, True ->
          ray(tl, y, x + 1, loop, None, is_inside, streak + 1, count + 1, tiles)
        False, _, False ->
          ray(tl, y, x + 1, loop, None, is_inside, streak, count, tiles)
      }
  }
}

fn count_insides(
  loop: List(Position),
  maze: Maze,
  y: Int,
  count: Int,
  tiles: Tiles,
) -> Int {
  case maze {
    [] -> count
    [hd, ..tl] -> {
      let row_count = ray(hd, y, 0, loop, None, False, 0, 0, tiles)
      count_insides(loop, tl, y + 1, count + row_count, tiles)
    }
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)
  let #(maze, starting_position) = parse_input(file)
  let tiles = dict.from_list(tiles_list)

  maze
  |> get_loop(starting_position, starting_position, #(-2, -2), [], tiles)
  |> count_insides(maze, 0, 0, tiles)
  |> int.to_string()
  |> io.print()
}
