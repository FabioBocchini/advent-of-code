import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order, Eq}
import gleam/result
import gleam/string
import utils
import simplifile

const input_path = "./inputs/d7"

pub type Hand {
  Hand(cards: List(String), hand_type: String, bid: Int)
}

const card_order = [
  "J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A",
]

const hand_order = [
  "HighC", "OneP", "TwoP", "ThreeOAK", "FullH", "FourOAK", "FiveOAK",
]

fn get_hand_type(cards: List(String)) -> String {
  let groups = list.group(cards, fn(i) { i })

  let jokers_num =
    groups
    |> dict.get("J")
    |> result.unwrap([])
    |> list.length()

  let #(group_num, max_size) =
    dict.fold(groups, #(0, 0), fn(acc, _, v) {
      let #(g, s) = acc
      #(g + 1, int.max(list.length(v), s))
    })

  let #(group_num, max_size) = case jokers_num {
    0 | 5 -> #(group_num, max_size)
    _ -> #(group_num - 1, max_size + jokers_num)
  }

  case group_num {
    1 -> "FiveOAK"
    2 ->
      case max_size {
        3 -> "FullH"
        4 | _ -> "FourOAK"
      }
    3 ->
      case max_size {
        2 -> "TwoP"
        3 | _ -> "ThreeOAK"
      }
    4 -> "OneP"
    5 | _ -> "HighC"
  }
}

fn compare_hands_aux(cards_a: List(String), cards_b: List(String)) -> Order {
  case cards_a, cards_b {
    [a, ..tla], [b, ..tlb] ->
      case a == b {
        True -> compare_hands_aux(tla, tlb)
        False -> utils.compare_from_list(card_order)(a, b)
      }

    _, _ -> Eq
  }
}

fn compare_hands(a: Hand, b: Hand) -> Order {
  let ord = utils.compare_from_list(hand_order)(a.hand_type, b.hand_type)
  case ord {
    Eq -> compare_hands_aux(a.cards, b.cards)
    _ -> ord
  }
}

fn parse_input(input: String) -> List(Hand) {
  use row <- list.map(string.split(input, "\n"))
  let assert [c, b] = string.split(row, " ")
  let assert Ok(bid) = int.parse(b)
  let cards = string.split(c, "")
  let hand_type = get_hand_type(cards)

  Hand(cards, hand_type, bid)
}

fn get_result(hands: List(Hand)) -> Int {
  use acc, hand, i <- list.index_fold(hands, 0)
  acc + { i + 1 } * hand.bid
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> list.sort(compare_hands)
  |> get_result()
  |> int.to_string()
  |> io.print()
}
