import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "./inputs/d5"

pub type MapRow {
  MapRow(from: Int, to: Int, jump: Int)
}

pub type Map =
  List(MapRow)

fn get_seeds(seeds_str: String) -> List(Int) {
  let assert [_, seeds_str] = string.split(seeds_str, ":")
  seeds_str
  |> string.split(" ")
  |> list.filter_map(int.parse)
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

  MapRow(from, from + length, to - from)
}

fn get_dest(source: Int, map: Map) -> Int {
  case
    list.find(map, fn(res_r) { res_r.from <= source && res_r.to >= source })
  {
    Ok(r) -> source + r.jump
    Error(_) -> source
  }
}

fn get_location(source: Int, maps: List(Map)) -> Int {
  case maps {
    [] -> source
    [map, ..tl] ->
      source
      |> get_dest(map)
      |> get_location(tl)
  }
}

fn get_min_location(
  seeds: List(Int),
  maps: List(Map),
  prev_location: Int,
) -> Int {
  case seeds {
    [] -> prev_location
    [seed, ..tl] -> {
      let location = get_location(seed, maps)
      let min_location = case prev_location {
        -1 -> location
        _ -> int.min(prev_location, location)
      }
      get_min_location(tl, maps, min_location)
    }
  }
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)
  let assert [seeds_str, ..maps_str] = string.split(file, "\n\n")
  let maps = get_maps(maps_str)
  seeds_str
  |> get_seeds
  |> get_min_location(maps, -1)
  |> int.to_string
  |> io.print
}
