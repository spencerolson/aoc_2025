import gleam/io
import part_01
import part_02

pub fn main() {
  io.println("Day 03 Part 01 Result:")
  part_01.main() |> echo
  io.println("Day 03 Part 02 Result:")
  part_02.main() |> echo
}
