import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils
import simplifile

const input_path = "./inputs/d8"

type Node {
  Node(l: String, r: String)
}

pub type Graph =
  Dict(String, Node)

fn get_graph(rows: List(String)) -> #(Graph, List(String)) {
  list.fold(rows, #(dict.new(), []), fn(acc, r) {
    let #(acc_dict, acc_starting) = acc
    let assert [id, dirs] = string.split(r, " = ")
    let left = string.slice(dirs, 1, 3)
    let right = string.slice(dirs, 6, 3)
    let new_start = case string.ends_with(id, "A") {
      True -> [id, ..acc_starting]
      False -> acc_starting
    }
    #(dict.insert(acc_dict, id, Node(left, right)), new_start)
  })
}

fn get_walk_count(
  graph: Graph,
  dirs: String,
  remaining_dirs: String,
  pos: String,
  count: Int,
) -> Int {
  use <- bool.guard(when: string.ends_with(pos, "Z"), return: count)
  let remaining_dirs = case remaining_dirs {
    "" -> dirs
    _ -> remaining_dirs
  }

  let assert Ok(curr_node) = dict.get(graph, pos)
  let assert Ok(#(dir, next_remaining_dirs)) =
    string.pop_grapheme(remaining_dirs)

  let next_pos = case dir {
    "L" <> _ -> curr_node.l
    "R" <> _ | _ -> curr_node.r
  }

  get_walk_count(graph, dirs, next_remaining_dirs, next_pos, count + 1)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)
  let assert [directions, _, ..rows] = string.split(file, "\n")
  let #(graph, start_pos) = get_graph(rows)

  start_pos
  |> list.map(fn(p) { get_walk_count(graph, directions, directions, p, 0) })
  |> list.fold(1, fn(acc, c) { utils.lcm(acc, c) })
  |> int.to_string()
  |> io.print()
}
