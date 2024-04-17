import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "./inputs/d6"

pub type Race {
  Race(time: Int, dist: Int)
}

fn parse_input_row(row: String) -> Int {
  row
  |> string.split(" ")
  |> list.filter(fn(i) { result.is_ok(int.parse(i)) })
  |> string.join("")
  |> int.parse()
  |> result.unwrap(0)
}

fn parse_input(file: String) -> Race {
  let assert [t_str, d_str] = string.split(file, "\n")
  let time = parse_input_row(t_str)
  let dist = parse_input_row(d_str)
  Race(time, dist)
}

fn get_win_count(race: Race) -> Int {
  list.fold(list.range(1, race.time - 1), 0, fn(acc, t) {
    let dist_travelled = t * { race.time - t }
    case dist_travelled > race.dist {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> get_win_count()
  |> int.to_string()
  |> io.print()
}
