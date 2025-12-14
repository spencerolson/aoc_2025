import gleam/io
import part_01
import part_02

pub fn main() -> Nil {
  io.println("Part 1: ")
  let _ =part_01.main()
  io.println("Part 2: ")
  let _ = part_02.main()
  Nil
}
