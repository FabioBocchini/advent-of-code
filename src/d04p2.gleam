import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/string
import simplifile

const input_path = "./inputs/d4"

type Game {
  Game(winning: List(String), playing: List(String), copies: Int)
}

fn get_row_points(winning: List(String), playing: List(String)) -> Int {
  list.fold(playing, 0, fn(acc, n) {
    case list.contains(winning, n) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn update_games(
  index: Int,
  row_points: Int,
  games: Dict(String, Game),
  game: Game,
) -> Dict(String, Game) {
  list.fold(list.range(index, index + row_points), games, fn(acc, i) {
    dict.update(acc, int.to_string(i), fn(g) {
      let assert Some(g) = g
      Game(..g, copies: g.copies + game.copies)
    })
  })
}

fn get_points(games: Dict(String, Game), index: Int, points: Int) -> Int {
  case dict.get(games, int.to_string(index)) {
    Ok(game) -> {
      let row_points = get_row_points(game.winning, game.playing)
      let updated_games = update_games(index, row_points, games, game)
      get_points(updated_games, index + 1, points + game.copies)
    }
    Error(_) -> points
  }
}

fn solve(rows: List(String)) -> Int {
  let games =
    list.fold(rows, dict.new(), fn(acc, r) {
      let assert [game, numbers] = string.split(r, ":")
      let assert [_, id] =
        game
        |> string.split(" ")
        |> list.filter(fn(c) { c != "" })

      let assert [winning, playing] =
        numbers
        |> string.split("|")
        |> list.map(fn(s) {
          s
          |> string.split(" ")
          |> list.filter(fn(c) { c != "" })
        })

      dict.insert(acc, id, Game(winning: winning, playing: playing, copies: 1))
    })

  get_points(games, 1, 0)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> string.split("\n")
  |> solve
  |> int.to_string
  |> io.print
}
