import gleam/list
import gleam/option.{type Option, None, Some}

pub type Item(a) {
  Item(value: a, priority: Int)
}

pub type PrioQ(a) =
  List(Item(a))

pub fn new() -> PrioQ(a) {
  []
}

pub fn from_list(l: List(#(Int, a))) -> PrioQ(a) {
  list.fold(l, [], fn(acc, i) {
    let #(priority, value) = i
    [Item(priority: priority, value: value), ..acc]
  })
}

pub fn insert(prioq: PrioQ(a), priority: Int, value: a) -> PrioQ(a) {
  [Item(value: value, priority: priority), ..prioq]
}

pub fn pop(prioq: PrioQ(a)) -> #(Option(a), PrioQ(a)) {
  let #(_, min_item, rest) =
    list.fold(prioq, #(-1, None, []), fn(acc, item) {
      let #(min_priority, min_value, rest): #(Int, Option(a), List(Item(a))) =
        acc

      case min_priority == -1 || item.priority < min_priority, min_value {
        True, Some(old_v) -> {
          let new_rest = [Item(value: old_v, priority: min_priority), ..rest]
          #(item.priority, Some(item.value), new_rest)
        }
        True, None -> #(item.priority, Some(item.value), rest)
        _, _ -> #(min_priority, min_value, [item, ..rest])
      }
    })

  #(min_item, rest)
}
