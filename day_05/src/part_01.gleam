import gleam/list
import gleam/int
import gleam/io
import gleam/string
import simplifile

type Category {
  Fresh
  Available
}

pub fn main() {
  case simplifile.read("input.txt") {
    Error(_) -> io.println("Failed to read input.txt")
    Ok(input) -> {
      let lines = input |> string.trim() |> string.split("\n")
      let #(_, _, count) = count_fresh_in_stock(lines)
      echo count
      Nil
    }
  }
}

fn count_fresh_in_stock(lines: List(String)) {
    use #(category, known_fresh, count), line <- list.fold(lines, #(Fresh, [], 0))
    case line, category {
      "", _ -> #(Available, known_fresh, count)
      line, Fresh -> {
        case string.split_once(line, "-") {
          Error(_) -> panic as "Invalid line format"
          Ok(#(start, end)) -> {
            case int.parse(start), int.parse(end) {
              Ok(start), Ok(end) -> #(Fresh, [#(start, end), ..known_fresh], count)
              _, _ -> panic as "Invalid start or end integer"
            }
          }
        }
      }
      line, Available -> {
        case int.parse(line) {
          Ok(id) -> {
            case is_fresh(id, known_fresh) {
              True -> #(Available, known_fresh, count + 1)
              False -> #(Available, known_fresh, count)
            }
          }
          Error(_) -> panic as "Invalid available item integer"
        }
      }
    }
}

fn is_fresh(id: Int, known_fresh: List(#(Int, Int))) -> Bool {
  list.any(known_fresh, fn (range) {
    id >= range.0 && id <= range.1
  })
}
