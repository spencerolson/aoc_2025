import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  use ids <- result.try(parse_input())
  let sum = sum_invalid_ids(ids)
  io.println("Part 1: sum of invalid IDs: " <> int.to_string(sum))
  Ok(Nil)
}

fn parse_input() -> Result(List(Int), Nil) {
  use input_str <- result.try(read_input())
  use ranges <- result.try(input_str
    |> string.trim()
    |> string.split(",")
    |> list.try_map(parse_range_str))
  Ok(list.flatten(ranges))
}

fn read_input() -> Result(String, Nil) {
  case simplifile.read("input.txt") {
    Error(_) -> Error(Nil)
    Ok(content) -> Ok(content)
  }
}

fn parse_range_str(range_str: String) -> Result(List(Int), Nil) {
  case string.split(range_str, "-") {
    [start_str, end_str] -> {
      use start <- result.try(int.parse(start_str))
      use end <- result.try(int.parse(end_str))
      Ok(list.range(start, end))
    }
    _ -> Error(Nil)
  }
}

fn sum_invalid_ids(ids: List(Int)) {
  list.fold(ids, 0, fn (acc, id) {
    case is_invalid(id) {
      True -> acc + id
      False -> acc
    }
  })
}

fn is_invalid(id: Int) {
  let id_str = int.to_string(id)
  case string.length(id_str) % 2 {
    0 -> has_repeated_substring(id_str)
    _ -> False
  }
}

fn has_repeated_substring(str: String) {
  let mid = string.length(str) / 2
  let left = string.slice(str, 0, mid)
  let right = string.slice(str, mid, string.length(str))
  left == right
}
