import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type MathProblem {
  MathProblem(operator: String, operands: List(Int))
}

pub fn main() {
  use input <- result.map(simplifile.read("input.txt"))
  input
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.transpose()
  |> grand_total(MathProblem("", []), 0)
}

fn grand_total(columns: List(List(String)), problem: MathProblem, total: Int) {
  case columns {
    [] -> {
      solve_problem(problem) + total
    }
    [column, ..rest] -> {
      case is_separator(column) {
        True -> {
          grand_total(
            rest,
            MathProblem("", []),
            total + solve_problem(problem)
          )
        }
        False -> {
          case list.reverse(column) {
            [first, ..number_parts] -> {
              let new_operator = case first {
                o if o == "+" || o == "*" -> o
                " " -> problem.operator
                _ -> panic as { "Unknown value in operator slot: " <> first }
              }
              let number = number_from_parts(number_parts, "")

              grand_total(
                rest,
                MathProblem(new_operator, [number, ..problem.operands]),
                total,
              )
            }
            [] -> panic as { "Empty column encountered" }
          }
        }
      }
    }
  }
}

fn is_separator(column: List(String)) -> Bool {
  list.all(column, fn (c) { c == " " })
}

fn solve_problem(problem: MathProblem) -> Int {
  case problem.operator {
    "+" -> int.sum(problem.operands)
    "*" -> int.product(problem.operands)
    o -> panic as { "Unknown operator: " <> o }
  }
}

fn number_from_parts(parts: List(String), acc: String) -> Int {
  case parts {
    [] -> {
      case int.parse(acc) {
        Ok(n) -> n
        Error(_) -> panic as { "Failed to parse number: " <> acc }
      }
    }
    [part, ..rest] -> {
      case part {
        " " -> number_from_parts(rest, acc)
        part -> number_from_parts(rest, part <> acc)
      }
    }
  }
}
