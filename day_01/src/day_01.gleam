import gleam/result
import gleam/int
import gleam/io
import gleam/string
import simplifile

pub fn main() -> Result(String, _) {
  use input <- result.try(read_input())
  use password <- result.try(find_password(input))
  io.println("Password: " <> password)
  Ok(password)
}

fn read_input() {
  case simplifile.read("input.txt") {
    Error(_) -> Error(Nil)
    Ok(content) -> Ok(content)
  }
}

fn find_password(input: String) {
  input
  |> string.split("\n")
  |> do_find_password(50, 0)
}

fn do_find_password(rotations: List(String), position: Int, zeros_encountered: Int) {
  case rotations {
    [] -> Ok(int.to_string(zeros_encountered))
    ["", ..rotations] -> do_find_password(rotations, position, zeros_encountered)
    [rotation, ..rotations] -> {
      use position <- result.try(rotate(rotation, position))
      let zeros_encountered = case position {
        0 -> zeros_encountered + 1
        _ -> zeros_encountered
      }
      do_find_password(rotations, position, zeros_encountered)
    }
  }
}

fn rotate(rotation: String, position: Int) {
  use #(direction, clicks_str) <- result.try(string.pop_grapheme(rotation))
  use clicks <- result.try(int.parse(clicks_str))
  case direction {
    "L" -> Ok(turn_dial_left(clicks, position))
    "R" -> Ok(turn_dial_right(clicks, position))
    _ -> {
      io.println("Unknown direction: " <> direction <> ". Ignoring this rotation.")
      Error(Nil)
    }
  }
}

fn turn_dial_left(clicks: Int, position: Int) {
  case clicks, position {
    0, _ -> position
    _, 0 -> turn_dial_left(clicks - 1, 99)
    _, _ -> turn_dial_left(clicks - 1, position - 1)
  }
}

fn turn_dial_right(clicks: Int, position: Int) {
  case clicks, position {
    0, _ -> position
    _, 99 -> turn_dial_right(clicks - 1, 0)
    _, _ -> turn_dial_right(clicks - 1, position + 1)
  }
}
