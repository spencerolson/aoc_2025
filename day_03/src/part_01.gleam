import gleam/int
import gleam/list
import gleam/string
import simplifile

type Bank = List(Int)
type Banks = List(Bank)

pub fn main() -> Int {
  parse_input() |> calc_total_joltage()
}

fn parse_input() -> Banks {
  let assert Ok(input_str) = simplifile.read("input.txt")
  input_str
    |> string.trim()
    |> string.split("\n")
    |> list.map(fn (line) {
      line
      |> string.to_graphemes
      |> list.map(fn (joltage_str) {
        let assert Ok(joltage) = int.parse(joltage_str)
        joltage
      })
    })
}

fn calc_total_joltage(banks: Banks) -> Int {
  list.fold(banks, 0, fn (total, bank) {
    total + calc_max_joltage(bank)
  })
}

fn calc_max_joltage(bank: Bank) -> Int {
  let last_index = list.length(bank) - 1

  let #(jolt_one, jolt_two) = list.index_fold(bank, #(0, 0), fn (joltages, cur_joltage, index){
    let #(jolt_one, jolt_two) = joltages
    case cur_joltage {
      j if j > jolt_one && index != last_index -> #(j, 0)
      j if j > jolt_two -> #(jolt_one, j)
      _ -> #(jolt_one, jolt_two)
    }
  })
  let max_joltage_str = int.to_string(jolt_one) <> int.to_string(jolt_two)
  let assert Ok(max_joltage) = int.parse(max_joltage_str)
  max_joltage
}
