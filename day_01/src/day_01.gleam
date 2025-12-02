import gleam/int
import gleam/io
import gleam/string
import simplifile

pub fn main() {
  case simplifile.read("input.txt") {
    Ok(input) -> {
      let password = find_password(input)
      io.println("The password is: " <> password)
    }
    Error(reason) -> io.println("Failed to read input.txt file. Error is:\n\n" <> simplifile.describe_error(reason))
  }
}

fn find_password(input: String) -> String {
  input
  |> string.split("\n")
  |> do_find_password(50, 0)
}

fn do_find_password(rotations: List(String), position: Int, zeros_encountered: Int) -> String{
  case rotations {
    [] -> int.to_string(zeros_encountered)
    [rotation, ..rotations] -> {
      let position = rotate(rotation, position)
      let zeros_encountered = case position {
        0 -> zeros_encountered + 1
        _ -> zeros_encountered
      }
      do_find_password(rotations, position, zeros_encountered)
    }
  }
}

fn rotate(rotation: String, position: Int) -> Int {
  case string.pop_grapheme(rotation) {
    Ok(#(direction, clicks_str)) -> {
      case int.parse(clicks_str) {
        Ok(clicks) -> {
          case direction {
            "L" -> turn_dial_left(clicks, position)
            "R" -> turn_dial_right(clicks, position)
            _ -> {
              io.println("Unknown direction: " <> direction <> ". Ignoring this rotation.")
              position
            }
          }
        }
        Error(_) -> {
          position
        }
      }
    }
    Error(_) -> {
      position
    }
  }
}

fn turn_dial_left(clicks: Int, position: Int) -> Int {
  case clicks, position {
    0, _ -> position
    _, 0 -> turn_dial_left(clicks - 1, 99)
    _, _ -> turn_dial_left(clicks - 1, position - 1)
  }
}

fn turn_dial_right(clicks: Int, position: Int) -> Int {
  case clicks, position {
    0, _ -> position
    _, 99 -> turn_dial_right(clicks - 1, 0)
    _, _ -> turn_dial_right(clicks - 1, position + 1)
  }
}
