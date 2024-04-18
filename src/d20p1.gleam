import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/queue.{type Queue}
import gleam/string
import simplifile

const input_path = "./inputs/d20"

type Module {
  Broadcaster(out: List(String))
  FlipFlop(out: List(String), state: Bool)
  Conjunction(out: List(String), in: Dict(String, Bool))
}

type ModuleConfig =
  Dict(String, Module)

type Pulse {
  Pulse(from: String, high: Bool, to: String)
}

fn parse_input(input: String) -> ModuleConfig {
  let #(modules, conjunctions) =
    input
    |> string.split("\n")
    |> list.fold(#([], []), fn(acc, row) {
      let #(modules, conjunctions) = acc
      let assert [name_str, out_str] = string.split(row, " -> ")
      let out = string.split(out_str, ", ")
      case name_str {
        "%" <> name -> #(
          [#(name, FlipFlop(state: False, out: out)), ..modules],
          conjunctions,
        )
        "&" <> name -> #(
          [#(name, Conjunction(in: dict.new(), out: out)), ..modules],
          [name, ..conjunctions],
        )
        "broadcaster" | _ -> #(
          [#("broadcaster", Broadcaster(out: out)), ..modules],
          conjunctions,
        )
      }
    })

  list.fold(modules, dict.new(), fn(acc, m) {
    let #(name, module) = m
    use acc_2, o <- list.fold(module.out, acc)
    case list.contains(conjunctions, o) {
      False -> acc_2
      True -> {
        use opt_in <- dict.update(acc_2, o)
        let new_in = #(name, False)
        case opt_in {
          Some(in) -> [new_in, ..in]
          None -> [new_in]
        }
      }
    }
  })
  |> dict.to_list()
  |> list.fold(dict.from_list(modules), fn(acc, c) {
    let #(c_name, c_in) = c
    use opt_m <- dict.update(acc, c_name)
    let assert Some(Conjunction(out, _)) = opt_m
    Conjunction(out: out, in: dict.from_list(c_in))
  })
}

fn get_new_pulses(from: String, high: Bool, out: List(String)) -> List(Pulse) {
  list.map(out, fn(o) { Pulse(from: from, high: high, to: o) })
}

fn process_single_pulse(
  module_config: ModuleConfig,
  pulse: Pulse,
) -> #(ModuleConfig, List(Pulse)) {
  case dict.get(module_config, pulse.to) {
    Ok(Broadcaster(out)) -> {
      let new_pulses = get_new_pulses(pulse.to, pulse.high, out)
      #(module_config, new_pulses)
    }

    Ok(FlipFlop(out, state)) if !pulse.high -> {
      let new_module_config =
        dict.update(module_config, pulse.to, fn(opt_m) {
          let assert Some(FlipFlop(_, _)) = opt_m
          FlipFlop(out: out, state: !state)
        })

      let new_pulses = get_new_pulses(pulse.to, !state, out)
      #(new_module_config, new_pulses)
    }
    Ok(Conjunction(out, in)) -> {
      let new_in = dict.update(in, pulse.from, fn(_) { pulse.high })

      let new_module_config =
        dict.update(module_config, pulse.to, fn(opt_m) {
          let assert Some(Conjunction(_, _)) = opt_m
          Conjunction(out, new_in)
        })

      let new_pulses =
        new_in
        |> dict.values
        |> list.any(fn(h) { h == False })
        |> get_new_pulses(pulse.to, _, out)

      #(new_module_config, new_pulses)
    }
    _ -> #(module_config, [])
  }
}

fn process_pulses(
  module_config: ModuleConfig,
  pulses: Queue(Pulse),
  low_count: Int,
  high_count: Int,
) -> #(ModuleConfig, Int, Int) {
  case queue.pop_front(pulses) {
    Error(_) -> #(module_config, low_count, high_count)
    Ok(#(pulse, tl)) -> {
      let #(new_low, new_high) = case pulse.high {
        False -> #(low_count + 1, high_count)
        True -> #(low_count, high_count + 1)
      }
      let #(new_module_config, new_pulses) =
        process_single_pulse(module_config, pulse)
      let new_queue = list.fold(new_pulses, tl, queue.push_back)
      process_pulses(new_module_config, new_queue, new_low, new_high)
    }
  }
}

fn solve(module_config: ModuleConfig) -> Int {
  let button_press = Pulse(from: "", high: False, to: "broadcaster")

  let #(_, low, high) =
    list.fold(list.range(1, 1000), #(module_config, 0, 0), fn(acc, _) {
      let #(mc_acc, low_pulses, high_pulses) = acc
      process_pulses(
        mc_acc,
        queue.from_list([button_press]),
        low_pulses,
        high_pulses,
      )
    })

  low * high
}

pub fn main() {
  let assert Ok(file) = simplifile.read(input_path)

  file
  |> parse_input()
  |> solve()
  |> int.to_string()
  |> io.print()
}
