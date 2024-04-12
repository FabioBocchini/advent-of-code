import gleam/dict.{type Dict}
import gleam/list

pub type Set(a) =
  Dict(a, Bool)

pub fn new() -> Set(a) {
  dict.new()
}

pub fn from_list(l: List(a)) -> Set(a) {
  l
  |> list.map(fn(i) { #(i, True) })
  |> dict.from_list()
}

pub fn contains(set: Set(a), item: a) -> Bool {
  dict.has_key(set, item)
}

pub fn insert(set: Set(a), item: a) -> Set(a) {
  dict.insert(set, item, True)
}

pub fn size(set: Set(a)) -> Int {
  dict.size(set)
}
