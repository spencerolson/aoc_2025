import gleam/list
import gleam/int
import gleam/result
import gleam/string
import simplifile

type Category {
  Fresh
  Available
}

pub fn main() {
  use input <- result.map(simplifile.read("input.txt"))
  let lines = input |> string.trim() |> string.split("\n")
  let #(_, _, count) = count_fresh_in_stock(lines)
  echo count
}

fn count_fresh_in_stock(lines: List(String)) {
  use #(category, known_fresh, count), line <- list.fold(lines, #(Fresh, [], 0))
  case line, category {
    "", _ -> #(Available, known_fresh, count)
    line, Fresh -> process_fresh_line(line, known_fresh, count)
    line, Available -> process_available_line(line, known_fresh, count)
  }
}

fn process_fresh_line(line: String, known_fresh: List(#(Int, Int)), count: Int) {
  let range = {
    use #(start, end) <- result.try(string.split_once(line, "-"))
    use start <- result.try(int.parse(start))
    use end <- result.map(int.parse(end))
    #(start, end)
  }

  case range {
    Ok(range) -> #(Fresh, [range, ..known_fresh], count)
    Error(_) -> panic as "Invalid fresh line format or integers"
  }
}

fn process_available_line(line: String, known_fresh: List(#(Int, Int)), count: Int) {
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

fn is_fresh(id: Int, known_fresh: List(#(Int, Int))) -> Bool {
  list.any(known_fresh, fn (range) {
    id >= range.0 && id <= range.1
  })
}
