import part_01
// import part_02
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn part_1_test() {
  let result = part_01.main()

  assert result == Ok(6100348226985)
}

// pub fn part_2_test() {
//   let result = part_02.main()

//   assert result == Ok(3263827)
// }
