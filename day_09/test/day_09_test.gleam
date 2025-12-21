import part_01
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn part_1_test() {
  let result = part_01.main()

  assert result == Ok(50)
}
