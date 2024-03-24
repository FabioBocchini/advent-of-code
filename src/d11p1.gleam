import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d11"

type Point {
  Point(y: Int, x: Int)
}

type Points =
  List(Point)

fn parse_items(
  items: List(String),
  galaxies: List(Point),
  exp_col: List(Int),
  x: Int,
  y: Int,
) -> #(Points, List(Int)) {
  case items {
    [] -> #(galaxies, exp_col)
    [hd, ..tl] -> {
      let #(new_galaxies, new_exp_col) = case hd, y {
        "#", 0 -> #([Point(y, x), ..galaxies], exp_col)
        "#", _ -> #(
          [Point(y, x), ..galaxies],
          list.filter(exp_col, fn(i) { i != x }),
        )
        _, 0 -> #(galaxies, [x, ..exp_col])
        _, _ -> #(galaxies, exp_col)
      }
      parse_items(tl, new_galaxies, new_exp_col, x + 1, y)
    }
  }
}

fn parse_rows(
  rows: List(String),
  galaxies: Points,
  exp_row: List(Int),
  exp_col: List(Int),
  y: Int,
) -> #(Points, List(Int), List(Int)) {
  case rows {
    [] -> #(galaxies, exp_row, exp_col)
    [hd, ..tl] -> {
      let #(new_galaxies, new_exp_col) =
        hd
        |> string.split("")
        |> parse_items([], exp_col, 0, y)
      let new_exp_row = case new_galaxies {
        [] -> [y, ..exp_row]
        _ -> exp_row
      }
      parse_rows(
        tl,
        list.concat([new_galaxies, galaxies]),
        new_exp_row,
        new_exp_col,
        y + 1,
      )
    }
  }
}

fn parse_input(file: String) -> #(Points, List(Int), List(Int)) {
  let rows = string.split(file, "\n")
  parse_rows(rows, [], [], [], 0)
}

fn get_distance(
  points: #(Point, Point),
  exp_row: List(Int),
  exp_col: List(Int),
) -> Int {
  let get_x_dist = fn(ax, bx) {
    let n_exp_col =
      list.fold(exp_col, 0, fn(acc, c) {
        case c < ax && c > bx {
          True -> acc + 1
          False -> acc
        }
      })
    ax - bx + n_exp_col
  }

  let get_y_dist = fn(ay, by) {
    let n_exp_row =
      list.fold(exp_row, 0, fn(acc, r) {
        case r < ay && r > by {
          True -> acc + 1
          False -> acc
        }
      })
    ay - by + n_exp_row
  }

  let #(a, b) = points
  let x_dist = case a.x > b.x {
    True -> get_x_dist(a.x, b.x)
    False -> get_x_dist(b.x, a.x)
  }
  let y_dist = case a.y > b.y {
    True -> get_y_dist(a.y, b.y)
    False -> get_y_dist(b.y, a.y)
  }
  x_dist + y_dist
}

fn solve(galaxies: Points, exp_row: List(Int), exp_col: List(Int)) -> Int {
  galaxies
  |> list.combination_pairs()
  |> list.map(get_distance(_, exp_row, exp_col))
  |> list.fold(0, int.add)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)
  let #(galaxies, exp_row, exp_col) = parse_input(file)

  solve(galaxies, exp_row, exp_col)
  |> int.to_string()
  |> io.print()
}
