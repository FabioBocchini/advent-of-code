import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/string
import simplifile

const input_path = "./inputs/d19"

type Check {
  Check(from: String, check: Order, value: Int, dest: String)
}

type Rule {
  Rule(checks: List(Check), default: String)
}

type Workflows =
  Dict(String, Rule)

type Part =
  Dict(String, Int)

type Input {
  Input(workflows: Workflows, parts: List(Part))
}

fn parse_input(input: String) -> Input {
  let assert [workflows_str, parts_str] = string.split(input, "\n\n")
  let workflows =
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

      let assert [default] = default_lst

      let checks =
        list.map(checks_str, fn(c) {
          let assert Ok(#(from, c2)) = string.pop_grapheme(c)
          let assert Ok(#(check_str, c3)) = string.pop_grapheme(c2)
          let check = case check_str {
            "<" -> order.Lt
            _ -> order.Gt
          }
          let assert [value_str, dest] = string.split(c3, ":")
          let assert Ok(value) = int.parse(value_str)
          Check(from: from, check: check, value: value, dest: dest)
        })

      #(name, Rule(checks: checks, default: default))
    })
    |> dict.from_list()

  let parts =
    parts_str
    |> string.split("\n")
    |> list.map(fn(input) {
      input
      |> string.drop_left(1)
      |> string.drop_right(1)
      |> string.split(",")
      |> list.map(fn(p) {
        let assert Ok(#(part_type, p2)) = string.pop_grapheme(p)
        let assert Ok(#(_, p3)) = string.pop_grapheme(p2)
        let assert Ok(value) = int.parse(p3)
        #(part_type, value)
      })
      |> dict.from_list()
    })

  Input(workflows: workflows, parts: parts)
}

fn is_part_accepted(
  part: Part,
  workflows: Workflows,
  current_workflow: String,
) -> Bool {
  let assert Ok(rule) = dict.get(workflows, current_workflow)

  let rule_res =
    list.fold_until(rule.checks, rule.default, fn(acc, c) {
      let assert Ok(part_value) = dict.get(part, c.from)
      case int.compare(part_value, c.value) == c.check {
        True -> list.Stop(c.dest)
        False -> list.Continue(acc)
      }
    })

  case rule_res {
    "A" -> True
    "R" -> False
    new_w -> is_part_accepted(part, workflows, new_w)
  }
}

fn solve(input: Input) -> Int {
  use acc, p <- list.fold(input.parts, 0)
  case is_part_accepted(p, input.workflows, "in") {
    False -> acc
    True -> list.fold(dict.values(p), acc, int.add)
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
