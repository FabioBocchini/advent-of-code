import gleam/int
import gleam/io
import gleam/list
import gleam/string
import set.{type Set}
import simplifile

const input_path = "./inputs/d18"

type Position =
  #(Int, Int)

fn parse_input(input: String) -> List(#(String, Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(r) {
    let assert [dir, length_str, ..] = string.split(r, " ")
    let assert Ok(length) = int.parse(length_str)
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
  loop: List(Position),
) -> List(Position) {
  case rows {
    [] -> normalize(loop, dy, dx)
    [hd, ..tl] -> {
      let #(direction, count) = hd
      let #(y, x) = position
      let new_rows = case count {
        1 -> tl
        _ -> [#(direction, count - 1), ..tl]
      }
      let #(new_position, new_dy, new_dx) = case direction {
        "U" -> #(#(y - 1, x), dy + 1, dx)
        "D" -> #(#(y + 1, x), dy - 1, dx)
        "L" -> #(#(y, x - 1), dy, dx + 1)
        "R" | _ -> #(#(y, x + 1), dy, dx - 1)
      }
      let new_loop = [new_position, ..loop]
      get_map(new_rows, new_position, new_dy, new_dx, new_loop)
    }
  }
}

fn count_holes(loop: Set(Position), queue: List(Position)) -> Int {
  case queue {
    [] -> set.size(loop)
    [hd, ..tl] -> {
      let #(y, x) = hd
      let new_visited =
        list.filter([#(y - 1, x), #(y + 1, x), #(y, x - 1), #(y, x + 1)], fn(i) {
          !set.contains(loop, i)
        })
      let new_loop =
        list.fold(new_visited, loop, fn(acc, i) { set.insert(acc, i) })
      let new_queue = list.concat([new_visited, tl])
      count_holes(new_loop, new_queue)
    }
  }
}

fn solve(rows: List(#(String, Int))) -> Int {
  rows
  |> get_map(#(0, 0), 0, 0, [])
  |> set.from_list()
  |> count_holes([#(1, 1)])
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
