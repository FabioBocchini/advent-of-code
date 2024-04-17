import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils
import simplifile

const input_path = "./inputs/d5"

pub type MapRow {
  MapRow(from: Int, to: Int, jump: Int)
}

pub type Map =
  List(MapRow)

pub type SeedRange {
  SeedRange(from: Int, to: Int)
}

fn get_seed_ranges(seeds_str: String) -> List(SeedRange) {
  let assert [_, seeds_str] = string.split(seeds_str, ":")
  seeds_str
  |> string.split(" ")
  |> list.filter_map(int.parse)
  |> list.sized_chunk(2)
  |> list.map(fn(r) {
    let assert [f, l] = r
    SeedRange(from: f, to: f + l - 1)
  })
}

fn get_maps(rows: List(String)) -> List(Map) {
  use m <- list.map(rows)
  let maps =
    m
    |> string.split("\n")
    |> list.drop(1)

  use row <- list.map(maps)
  let assert [Ok(to), Ok(from), Ok(length)] =
    string.split(row, " ")
    |> list.map(int.parse)

  MapRow(from: from, to: from + length - 1, jump: to - from)
}

fn walk(source: Int, maps: List(Map), range_size: Int) -> #(Int, Int) {
  case maps {
    [] -> #(source, range_size)
    [hd, ..tl] ->
      case list.find(hd, fn(r) { r.from <= source && r.to >= source }) {
        Ok(row) -> {
          let min_range_size = int.min(range_size, row.to - source + 1)
          walk(source + row.jump, tl, min_range_size)
        }
        Error(_) -> {
          walk(source, tl, range_size)
        }
      }
  }
}

fn get_min_range_loc(range: SeedRange, maps: List(Map), loc: Int) -> Int {
  use <- bool.guard(when: range.from >= range.to, return: loc)

  let #(min_loc, min_range_size) = walk(range.from, maps, range.to - range.from)
  let next_loc = utils.min_pos(loc, min_loc)

  use <- bool.guard(when: min_range_size == 0, return: next_loc)

  let next_range = SeedRange(from: range.from + min_range_size, to: range.to)
  get_min_range_loc(next_range, maps, next_loc)
}

fn get_min_loc(ranges: List(SeedRange), maps: List(Map), loc: Int) -> Int {
  case ranges {
    [] -> loc
    [hd, ..tl] -> {
      let min_range_loc = get_min_range_loc(hd, maps, -1)
      let min_loc = utils.min_pos(loc, min_range_loc)
      get_min_loc(tl, maps, min_loc)
    }
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)
  let assert [seeds_str, ..maps_str] = string.split(file, "\n\n")
  let maps = get_maps(maps_str)

  seeds_str
  |> get_seed_ranges()
  |> get_min_loc(maps, -1)
  |> int.to_string()
  |> io.print()
}
