import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "./inputs/d13"

type Pattern =
  List(List(String))

fn parse_input(file: String) -> List(Pattern) {
  file
  |> string.split("\n\n")
  |> list.map(fn(p) {
    p
    |> string.split("\n")
    |> list.map(string.split(_, ""))
  })
}

fn check_mirror(p1: Pattern, p2: Pattern) -> Bool {
  case p1, p2 {
    [], _ | _, [] -> True
    [h1, ..r1], [h2, ..r2] ->
      case h1 == h2 {
        True -> check_mirror(r1, r2)
        False -> False
      }
  }
}

fn solve_horizontal_aux(
  p: Pattern,
  last_row: List(String),
  rev_p: Pattern,
  index: Int,
) -> Result(Int, Nil) {
  case p, last_row {
    [], _ -> Error(Nil)
    [hd, ..tl], [] -> solve_horizontal_aux(tl, hd, [hd], 1)
    [hd, ..tl], lr ->
      case hd == lr && check_mirror(p, rev_p) {
        True -> Ok(index)
        False -> solve_horizontal_aux(tl, hd, [hd, ..rev_p], index + 1)
      }
  }
}

fn solve_horizontal(pattern: Pattern) -> Result(Int, Nil) {
  solve_horizontal_aux(pattern, [], [], 0)
}

fn solve_vertical(pattern: Pattern) -> Int {
  pattern
  |> list.transpose()
  |> solve_horizontal()
  |> result.unwrap(0)
}

fn solve(patterns: List(Pattern)) -> Int {
  list.fold(patterns, 0, fn(acc, p) {
    case solve_horizontal(p) {
      Error(_) -> acc + solve_vertical(p)
      Ok(v) -> acc + 100 * v
    }
  })
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
