import gleam/int
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "./inputs/d15"

type Box =
  List(#(String, Int))

type Boxes =
  Dict(Int, Box)

fn parse_input(file: String) -> List(String) {
  file
  |> string.split(",")
}

fn hash(step: String) -> Int {
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

fn insert_lens(step: String, boxes: Boxes) -> Boxes {
  let assert [label, fl] = string.split(step, "=")
  let assert Ok(focal_length) = int.parse(fl)
  let box_n = hash(label)

  let box = result.unwrap(dict.get(boxes, box_n), [])
  let new_box = case list.key_find(box, label) {
    Ok(_) ->
      list.map(box, fn(i) {
        let #(l, _) = i
        case l == label {
          True -> #(label, focal_length)
          False -> i
        }
      })
    Error(_) -> [#(label, focal_length), ..box]
  }
  dict.insert(boxes, box_n, new_box)
}

fn remove_lens(step: String, boxes: Boxes) -> Boxes {
  let label = string.drop_right(step, 1)
  let box_n = hash(label)
  let box = result.unwrap(dict.get(boxes, box_n), [])
  let new_box =
    list.filter(box, fn(i) {
      let #(l, _) = i
      l != label
    })
  dict.insert(boxes, box_n, new_box)
}

fn solve(steps: List(String)) -> Int {
  steps
  |> list.fold(dict.new(), fn(acc, s) {
    case string.contains(s, "=") {
      True -> insert_lens(s, acc)
      False -> remove_lens(s, acc)
    }
  })
  |> dict.fold(0, fn(acc, k, v) {
    let box_value =
      v
      |> list.reverse()
      |> list.index_fold(0, fn(acc_2, l, i) {
        let #(_, focal_length) = l
        acc_2 + { 1 + k } * { i + 1 } * focal_length
      })

    acc + box_value
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
