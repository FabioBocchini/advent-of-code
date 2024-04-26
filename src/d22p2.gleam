import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d22"

type Brick {
  Brick(
    id: Int,
    x1: Int,
    y1: Int,
    z1: Int,
    x2: Int,
    y2: Int,
    z2: Int,
    held_by: List(Int),
  )
}

fn parse_input(input: String) -> List(Brick) {
  input
  |> string.split("\n")
  |> list.index_map(fn(r, i) {
    let assert [p1, p2] = string.split(r, "~")
    let assert [Ok(x1), Ok(y1), Ok(z1)] =
      string.split(p1, ",")
      |> list.map(int.parse)

    let assert [Ok(x2), Ok(y2), Ok(z2)] =
      string.split(p2, ",")
      |> list.map(int.parse)

    Brick(id: i, x1: x1, y1: y1, z1: z1, x2: x2, y2: y2, z2: z2, held_by: [])
  })
}

fn drop_bricks(bricks: List(Brick), dropped: List(Brick)) -> List(Brick) {
  case bricks {
    [] -> dropped
    [b, ..tl] -> {
      let #(new_base, held_by) =
        list.fold(dropped, #(0, []), fn(acc, d) {
          let #(acc_base, acc_held_by) = acc

          case acc_base <= d.z2 {
            True -> {
              let is_held =
                list.any(list.range(b.x1, b.x2), list.contains(
                  list.range(d.x1, d.x2),
                  _,
                ))
                && list.any(list.range(b.y1, b.y2), list.contains(
                  list.range(d.y1, d.y2),
                  _,
                ))

              case is_held {
                True if acc_base < d.z2 -> #(d.z2, [d.id])
                True if acc_base == d.z2 -> #(d.z2, [d.id, ..acc_held_by])
                _ -> acc
              }
            }
            False -> acc
          }
        })

      let new_z1 = new_base + 1

      let new_dropped = [
        Brick(..b, z1: new_z1, z2: new_z1 + b.z2 - b.z1, held_by: held_by),
        ..dropped
      ]

      drop_bricks(tl, new_dropped)
    }
  }
}

fn count_drops(bricks: List(Brick), count: Int) -> Int {
  case bricks {
    [] -> count
    [hd, ..tl] -> {
      let drops =
        list.fold(tl, [hd.id], fn(acc, b) {
          case b.held_by != [] && list.all(b.held_by, list.contains(acc, _)) {
            True -> [b.id, ..acc]
            False -> acc
          }
        })
      let new_count = count + list.length(drops) - 1
      count_drops(tl, new_count)
    }
  }
}

fn solve(bricks: List(Brick)) -> Int {
  bricks
  |> list.sort(fn(a, b) { int.compare(a.z1, b.z1) })
  |> drop_bricks([])
  |> list.reverse()
  |> count_drops(0)
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
