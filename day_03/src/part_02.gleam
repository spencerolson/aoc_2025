import gleam/int
import gleam/list
import gleam/string
import simplifile

type Bank = List(Int)

const num_bats = 12

pub fn main() -> Int {
  read_input()
  |> parse_banks()
  |> calc_total_joltage()
}

fn read_input() -> List(String) {
  let assert Ok(input_str) = simplifile.read("input.txt")

  input_str
  |> string.trim()
  |> string.split("\n")
}

fn parse_banks(lines) -> List(Bank) {
  list.map(lines, line_to_bank)
}

fn line_to_bank(line: String) -> Bank {
  line
  |> string.to_graphemes
  |> list.map(fn (joltage_str) {
    let assert Ok(joltage) = int.parse(joltage_str)
    joltage
  })
}

fn calc_total_joltage(banks: List(Bank)) -> Int {
  list.fold(banks, 0, fn (total, bank) {
    total + calc_max_joltage(bank)
  })
}

fn calc_max_joltage(bank: Bank) -> Int {
  bank
  |> select_batteries([])
  |> batteries_to_max_joltage()
}

fn select_batteries(bank: Bank, selected: List(Int)) -> List(Int) {
  case list.length(selected) == num_bats {
    True -> list.reverse(selected)
    False -> {
      let batteries_needed = num_bats - list.length(selected)
      let search_space = list.take(bank, list.length(bank) - batteries_needed + 1)
      let #(selected_battery, selected_index) = find_battery(search_space)

      bank
      |> list.drop(selected_index + 1)
      |> select_batteries([selected_battery, ..selected])
    }
  }
}

fn batteries_to_max_joltage(batteries: List(Int)) -> Int {
  let max_joltage_str = list.fold(batteries, "", fn (acc, joltage) {
    acc <> int.to_string(joltage)
  })
  let assert Ok(max_joltage) = int.parse(max_joltage_str)
  max_joltage
}

fn find_battery(bank: Bank) -> #(Int, Int) {
  list.index_fold(bank, #(0, 0), fn (current_max, joltage, index) {
    let #(max, _) = current_max
    case joltage > max {
      True -> #(joltage, index)
      False -> current_max
    }
  })
}
