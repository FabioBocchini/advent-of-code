import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/option.{None, Some}
import prioq.{type PrioQ}
import set.{type Set}
import simplifile

const input_path = "./inputs/d17"

type Direction {
  U
  D
  L
  R
}

type Position =
  #(Int, Int)

type Map =
  Dict(#(Int, Int), Int)

type Matrix {
  Matrix(map: Map, width: Int, height: Int)
}

type Node {
  Node(pos: Position, dir: Direction, dir_c: Int, dist: Int)
}

type Visited =
  #(Position, Direction, Int)

fn parse_input(file: String) -> Matrix {
  let m =
    file
    |> string.split("\n")
    |> list.index_map(fn(r, j) {
      string.split(r, "")
      |> list.index_map(fn(n, i) {
        let assert Ok(value) = int.parse(n)
        #(#(j, i), value)
      })
    })

  let height = list.length(m)
  let width = {
    let assert [hd, ..] = m
    list.length(hd)
  }
  let map =
    m
    |> list.flatten()
    |> dict.from_list()

  Matrix(map: map, width: width, height: height)
}

fn neighbours(map: Map, node: Node) -> List(Node) {
  let #(ny, nx) = node.pos

  use #(y, x, dir) <- list.filter_map([
    #(ny - 1, nx, U),
    #(ny + 1, nx, D),
    #(ny, nx + 1, R),
    #(ny, nx - 1, L),
  ])
  use v <- result.try(dict.get(map, #(y, x)))
  let new_dir_c = case node.dir == dir {
    True -> node.dir_c + 1
    False -> 1
  }
  case new_dir_c < 4, node.dir, dir {
    False, _, _ | _, U, D | _, D, U | _, L, R | _, R, L -> Error(Nil)
    True, _, _ ->
      Ok(Node(pos: #(y, x), dir: dir, dir_c: new_dir_c, dist: node.dist + v))
  }
}

fn dijkstra(
  map: Map,
  dest: Position,
  queue: PrioQ(Node),
  visited: Set(Visited),
) -> Int {
  let #(hd, tl) = prioq.pop(queue)
  case hd {
    None -> -1
    Some(u) if u.pos == dest -> u.dist
    Some(u) -> {
      let visited_key = #(u.pos, u.dir, u.dir_c)
      case set.contains(visited, visited_key) {
        True -> dijkstra(map, dest, tl, visited)
        False -> {
          let new_queue =
            list.fold(neighbours(map, u), queue, fn(acc, n) {
              prioq.insert(acc, n.dist, n)
            })
          let new_visited = set.insert(visited, visited_key)
          dijkstra(map, dest, new_queue, new_visited)
        }
      }
    }
  }
}

fn solve(matrix: Matrix) -> Int {
  let queue =
    prioq.new()
    |> prioq.insert(0, Node(pos: #(0, 0), dir: D, dir_c: 0, dist: 0))
  let dest = #(matrix.height - 1, matrix.width - 1)
  dijkstra(matrix.map, dest, queue, set.new())
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
