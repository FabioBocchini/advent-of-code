import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "./inputs/d12"

type Row {
  Row(springs: List(String), groups: List(Int))
}

fn parse_row(row: String) -> Row {
  let assert [springs_str, groups_str] = string.split(row, " ")
  let s = string.split(springs_str, "")
  let g =
    groups_str
    |> string.split(",")
    |> list.filter_map(int.parse)

  Row(springs: s, groups: g)
}

fn parse_input(file: String) -> List(Row) {
  file
  |> string.split("\n")
  |> list.map(parse_row)
}

fn solve_row(springs: List(String), groups: List(Int)) -> Int {
  case springs, groups {
    // if springs and groups are empty, case is possible
    [], [] -> 1
    // if springs is empty but groups are left, case is impossible
    [], _ -> 0
    s, [] ->
      // if case is empty but strings contains a #, case is impossible
      case list.contains(s, "#") {
        True -> 0
        False -> 1
      }
    [hs, ..ts], [hg, ..tg] -> {
      // if springs starts with . or ?, also check ts. if it's # we can't ignore it
      let new_count = case hs == "." || hs == "?" {
        True -> solve_row(ts, groups)
        False -> 0
      }

      let springs_len = list.length(springs)

      // check that the first hg characters of springs (call it sg) are a working group
      case
        // if hs is . ignore it
        { hs == "#" || hs == "?" }
        && // if hg is longer than springs ignore it
        hg <= springs_len
        && // if sg contains a . ignore it
        !list.contains(list.take(springs, hg), ".")
        && // if the spring after sg is # ignore it
        result.unwrap(list.at(springs, hg), ".") != "#"
      {
        // remove the checked sg + 1 character if it's present (already checked)
        True if hg == springs_len -> new_count + solve_row([], tg)
        True -> new_count + solve_row(list.drop(springs, hg + 1), tg)
        False -> new_count
      }
    }
  }
}

fn solve(rows: List(Row), count: Int) -> Int {
  case rows {
    [] -> count
    [hd, ..tl] -> {
      let new_count = solve_row(hd.springs, hd.groups)
      solve(tl, new_count + count)
    }
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve(0)
  |> int.to_string()
  |> io.print()
}
