import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d15"

fn parse_input(file: String) -> List(String) {
  file
  |> string.split(",")
}

fn solve_step(step: String) -> Int {
  step
  |> string.to_utf_codepoints()
  |> list.fold(0, fn(acc, c) {
    {
      c
      |> string.utf_codepoint_to_int()
      |> int.add(acc)
      |> int.multiply(17)
    }
    % 256
  })
}

fn solve(steps: List(String)) -> Int {
  list.fold(steps, 0, fn(acc, s) { acc + solve_step(s) })
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
