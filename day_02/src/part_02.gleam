import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  use ids <- result.try(parse_input())
  let sum = sum_invalid_ids(ids)
  io.println("Part 2: sum of invalid IDs: " <> int.to_string(sum))
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
  list.fold(ids, 0, add_if_invalid)
}

fn add_if_invalid(sum: Int, id: Int) -> Int {
  case is_invalid(id) {
    True -> sum + id
    False -> sum
  }
}

fn is_invalid(id: Int) -> Bool {
  id
  |> int.to_string()
  |> do_is_invalid(1)
}

fn do_is_invalid(str: String, pattern_len: Int) -> Bool {
  case string.length(str) {
    len if len < 2 -> False
    len if pattern_len > len / 2 -> False
    len -> {
      case create_test_str(str, len, pattern_len) == str {
        True -> True
        False -> do_is_invalid(str, pattern_len + 1)
      }
    }
  }
}

fn create_test_str(str: String, str_len: Int, pattern_len: Int) -> String {
  str
  |> string.slice(at_index: 0, length: pattern_len)
  |> string.repeat(times: str_len / pattern_len)
}
