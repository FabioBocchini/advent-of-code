import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order, Gt, Lt}
import gleam/string
import simplifile

const input_path = "./inputs/d19"

type Check {
  Check(from: String, check: Order, value: Int, dest: String)
}

type Workflows =
  Dict(String, List(Check))

type HyperRectangle =
  Dict(String, #(Int, Int))

fn parse_input(input: String) -> Workflows {
  let assert [workflows_str, _] = string.split(input, "\n\n")
  workflows_str
  |> string.split("\n")
  |> list.map(fn(input) {
    let assert [name, rest] = string.split(input, "{")

    let rest_lst =
      rest
      |> string.drop_right(1)
      |> string.split(",")

    let #(checks_str, default_lst) =
      list.split(rest_lst, list.length(rest_lst) - 1)

    let assert [default_dest] = default_lst
    let default_check =
      Check(from: "x", check: Gt, value: 0, dest: default_dest)

    let checks =
      list.map(checks_str, fn(c) {
        let assert Ok(#(from, c2)) = string.pop_grapheme(c)
        let assert Ok(#(check_str, c3)) = string.pop_grapheme(c2)
        let check = case check_str {
          "<" -> Lt
          _ -> Gt
        }
        let assert [value_str, dest] = string.split(c3, ":")
        let assert Ok(value) = int.parse(value_str)
        Check(from: from, check: check, value: value, dest: dest)
      })

    #(name, list.append(checks, [default_check]))
  })
  |> dict.from_list()
}

fn bisect_hyperrect(
  rect: HyperRectangle,
  check: Check,
) -> #(HyperRectangle, HyperRectangle) {
  let assert Ok(#(min, max)) = dict.get(rect, check.from)

  let #(t_min, t_max, f_min, f_max) = case check.check {
    Lt -> #(
      min,
      int.min(check.value - 1, max),
      int.max(check.value - 1, min),
      max,
    )
    _ -> #(int.max(check.value, min), max, min, int.min(check.value, max))
  }

  let t = dict.insert(rect, check.from, #(t_min, t_max))
  let f = dict.insert(rect, check.from, #(f_min, f_max))
  #(t, f)
}

fn process_hyperrect(
  rect: HyperRectangle,
  workflows: Workflows,
  rule: String,
) -> Int {
  case rule {
    "R" -> 0
    "A" ->
      rect
      |> dict.to_list()
      |> list.fold(1, fn(acc, i) {
        let #(_, #(min, max)) = i
        acc * { max - min }
      })
    _ -> {
      let assert Ok(checks) = dict.get(workflows, rule)
      let #(count, _) =
        list.fold(checks, #(0, rect), fn(acc, c) {
          let #(count, last_rect) = acc
          let #(r1, r2) = bisect_hyperrect(last_rect, c)
          let new_count = count + process_hyperrect(r1, workflows, c.dest)
          #(new_count, r2)
        })

      count
    }
  }
}

fn solve(workflows: Workflows) -> Int {
  [
    #("x", #(0, 4000)),
    #("m", #(0, 4000)),
    #("a", #(0, 4000)),
    #("s", #(0, 4000)),
  ]
  |> dict.from_list()
  |> process_hyperrect(workflows, "in")
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
