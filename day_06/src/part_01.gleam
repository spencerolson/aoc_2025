import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  use input <- result.map(simplifile.read("input.txt"))
  input
  |> string.split("\n")
  |> list.map(line_to_list)
  |> list.transpose()
  |> list.map(solve_problem)
  |> int.sum()
  |> echo
}

fn line_to_list(line: String) -> List(String) {
  line
  |> string.split(" ")
  |> list.filter(fn (s) { s != "" })
}

fn solve_problem(problem: List(String)) -> Int {
  case parse_problem(problem) {
    #("+", nums) -> int.sum(nums)
    #("*", nums) -> int.product(nums)
    #(o, _) -> panic as { "Unknown operator: " <> o }
  }
}

fn parse_problem(problem: List(String)) -> #(String, List(Int)) {
  let assert [operator, ..operands] = list.reverse(problem)
  let nums = operands |> list.map(int.parse) |> result.values()
  #(operator, nums)
}
