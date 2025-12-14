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
  let assert [operator, ..nums] = list.reverse(problem)
  let nums = list.map(nums, fn (n) {
    let assert Ok(num) = int.parse(n)
    num
  })
  case operator {
    "+" -> int.sum(nums)
    "*" -> int.product(nums)
    o -> panic as { "Unknown operator: " <> o }
  }
}
