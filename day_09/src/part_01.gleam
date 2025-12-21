import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("input.txt")
  input
  |> string.split("\n")
  |> list.map(to_coord)
  |> list.combination_pairs()
  |> list.map(to_area)
  |> list.max(int.compare)
}

fn to_coord(line: String) -> #(Int, Int) {
  let assert Ok(#(x, y)) = string.split_once(line, ",")
  let assert #(Ok(x), Ok(y)) = #(int.parse(x), int.parse(y))
  #(x, y)
}

fn to_area(coords: #(#(Int, Int), #(Int, Int))) {
  let #(x1, y1) = coords.0
  let #(x2, y2) = coords.1
  int.absolute_value(x1 - x2 + 1) * int.absolute_value(y1 - y2 + 1)
}