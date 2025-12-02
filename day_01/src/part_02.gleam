import gleam/result
import gleam/int
import gleam/io
import gleam/string
import simplifile

type DecodedInstruction = #(String, Int)

pub fn main() -> Result(String, Nil) {
  use input <- result.try(read_input())
  use password <- result.try(find_password(input))
  io.println("Part 2 Password: " <> password)
  Ok(password)
}

fn read_input() -> Result(String, Nil) {
  case simplifile.read("input.txt") {
    Error(_) -> Error(Nil)
    Ok(content) -> Ok(content)
  }
}

fn find_password(input: String) -> Result(String, Nil) {
  input
  |> string.split("\n")
  |> do_find_password(50, 0)
}

fn do_find_password(rotations: List(String), position: Int, zeros_passed: Int) -> Result(String, Nil) {
  case rotations {
    [] -> Ok(int.to_string(zeros_passed))
    ["", ..rotations] -> do_find_password(rotations, position, zeros_passed)
    [rotation, ..rotations] -> {
      use #(direction, clicks) <- result.try(read_instruction(instruction: rotation))
      use #(position, zeros_passed) <- result.try(rotate(direction, clicks, position, zeros_passed))
      do_find_password(rotations, position, zeros_passed)
    }
  }
}

fn read_instruction(instruction rotation: String) -> Result(DecodedInstruction, Nil) {
  use #(direction, clicks_str) <- result.try(string.pop_grapheme(rotation))
  use clicks <- result.try(int.parse(clicks_str))
  Ok(#(direction, clicks))
}

fn rotate(direction: String, clicks: Int, position: Int, zeros_passed: Int) -> Result(#(Int, Int), Nil) {
  case direction {
    "L" -> Ok(turn_dial_left(clicks, position, zeros_passed))
    "R" -> Ok(turn_dial_right(clicks, position, zeros_passed))
    _ -> Error(Nil)
  }
}

fn turn_dial_left(clicks: Int, position: Int, zeros_passed: Int) -> #(Int, Int) {
  case clicks, position {
    0, _ -> #(position, zeros_passed)
    _, 1 -> turn_dial_left(clicks - 1, 0, zeros_passed + 1)
    _, 0 -> turn_dial_left(clicks - 1, 99, zeros_passed)
    _, _ -> turn_dial_left(clicks - 1, position - 1, zeros_passed)
  }
}

fn turn_dial_right(clicks: Int, position: Int, zeros_passed: Int) -> #(Int, Int) {
  case clicks, position {
    0, _ -> #(position, zeros_passed)
    _, 99 -> turn_dial_right(clicks - 1, 0, zeros_passed + 1)
    _, _ -> turn_dial_right(clicks - 1, position + 1, zeros_passed)
  }
}
