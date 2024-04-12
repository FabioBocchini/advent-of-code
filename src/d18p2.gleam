import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d18"

type Position =
  #(Int, Int)

fn parse_input(input: String) -> List(#(String, Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(r) {
    let assert [_, _, d] = string.split(r, " ")
    let assert Ok(length) =
      string.slice(d, 2, 5)
      |> int.base_parse(16)
    let dir = case string.slice(d, 7, 1) {
      "0" -> "R"
      "1" -> "D"
      "2" -> "L"
      "3" -> "U"
      _ -> ""
    }
    #(dir, length)
  })
}

fn normalize(loop: List(Position), dy: Int, dx: Int) -> List(Position) {
  use acc, i <- list.fold(loop, [])
  let #(y, x) = i
  [#(y + dy, x + dx), ..acc]
}

fn get_map(
  rows: List(#(String, Int)),
  position: Position,
  dy: Int,
  dx: Int,
  corners: List(Position),
  border_length: Int,
) -> #(List(Position), Int) {
  case rows {
    [] -> #(normalize(corners, dy, dx), border_length)
    [hd, ..tl] -> {
      let #(direction, count) = hd
      let #(y, x) = position
      let #(new_position, new_dy, new_dx) = case direction {
        "U" -> #(#(y - count, x), dy + count, dx)
        "D" -> #(#(y + count, x), dy - count, dx)
        "L" -> #(#(y, x - count), dy, dx + count)
        "R" | _ -> #(#(y, x + count), dy, dx - count)
      }
      let new_corners = [new_position, ..corners]
      get_map(
        tl,
        new_position,
        new_dy,
        new_dx,
        new_corners,
        border_length + count,
      )
    }
  }
}

fn shoelace(
  corners: List(Position),
  border_length: Int,
  first_corner: Position,
  insides: Int,
) -> Int {
  case corners {
    [] -> int.absolute_value(insides) / 2 + border_length / 2 + 1
    [fst, ..tl] -> {
      let #(y1, x1) = fst
      let #(y2, x2) = case tl {
        [snd, ..] -> snd
        [] -> first_corner
      }
      let new_insides = { y1 + y2 } * { x1 - x2 }
      shoelace(tl, border_length, first_corner, insides + new_insides)
    }
  }
}

fn solve(rows: List(#(String, Int))) -> Int {
  let #(corners, border_length) = get_map(rows, #(0, 0), 0, 0, [], 0)
  let assert [first_corner, ..] = corners
  shoelace(corners, border_length, first_corner, 0)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
