import gleam/bool
import gleam/dict.{type Dict}
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

type Memo =
  Dict(#(List(String), List(Int)), Int)

fn parse_row(row: String) -> Row {
  let assert [springs_str, groups_str] = string.split(row, " ")

  let s =
    springs_str
    |> list.repeat(5)
    |> string.join("?")
    |> string.split("")

  let g =
    groups_str
    |> list.repeat(5)
    |> string.join(",")
    |> string.split(",")
    |> list.filter_map(int.parse)

  Row(springs: s, groups: g)
}

fn parse_input(file: String) -> List(Row) {
  file
  |> string.split("\n")
  |> list.map(parse_row)
}

fn solve_row_memo(
  springs: List(String),
  groups: List(Int),
  memo: Memo,
) -> #(Int, Memo) {
  let key = #(springs, groups)

  // return memoized value if it's present
  let memoized = dict.get(memo, key)
  use <- bool.lazy_guard(when: result.is_ok(memoized), return: fn() {
    #(result.unwrap(memoized, 0), memo)
  })

  case springs, groups {
    // if springs and groups are empty, case is possible
    [], [] -> #(1, memo)
    // if springs is empty but groups are left, case is impossible
    [], _ -> #(0, memo)
    s, [] ->
      // if case is empty but strings contains a #, case is impossible
      case list.contains(s, "#") {
        True -> #(0, memo)
        False -> #(1, memo)
      }
    [hs, ..ts], [hg, ..tg] -> {
      // if springs starts with . or ?, also check ts. if it's # we can't ignore it
      let #(count_1, memo_1) = case hs == "." || hs == "?" {
        True -> solve_row_memo(ts, groups, memo)
        False -> #(0, memo)
      }

      let springs_len = list.length(springs)

      // check that the first hg characters of springs (call it sg) are a working group
      let #(count_2, memo_2) = case
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
        True if hg == springs_len -> solve_row_memo([], tg, memo_1)
        True -> solve_row_memo(list.drop(springs, hg + 1), tg, memo_1)
        False -> #(0, memo_1)
      }

      let result = count_1 + count_2
      #(result, dict.insert(memo_2, key, result))
    }
  }
}

fn solve(rows: List(Row)) -> Int {
  list.fold(rows, 0, fn(acc, r) {
    let #(v, _) = solve_row_memo(r.springs, r.groups, dict.new())
    acc + v
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
