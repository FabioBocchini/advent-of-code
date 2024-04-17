import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d6"

pub type Race {
  Race(time: Int, dist: Int)
}

fn parse_input_row(row: String) -> List(Int) {
  row
  |> string.split(" ")
  |> list.filter_map(fn(i) { int.parse(i) })
}

fn parse_input(file: String) -> List(Race) {
  let assert [t_str, d_str] = string.split(file, "\n")
  let times = parse_input_row(t_str)
  let dists = parse_input_row(d_str)
  list.map2(times, dists, fn(t, d) { Race(t, d) })
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

fn solve(races: List(Race), res: Int) -> Int {
  case races {
    [] -> res
    [hd, ..tl] -> {
      let win_count = get_win_count(hd)
      solve(tl, res * win_count)
    }
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve(1)
  |> int.to_string()
  |> io.print()
}
