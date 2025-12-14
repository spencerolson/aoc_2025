import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile

type BoundaryKind {
  Start
  End
}

type Boundary {
  Boundary(kind: BoundaryKind, value: Int)
}

pub fn main() {
  use input <- result.map(simplifile.read("input.txt"))
  input
  |> string.split("\n")
  |> create_boundaries()
  |> list.sort(compare)
  |> count_ids()
  |> echo
}

fn create_boundaries(lines: List(String)) -> List(Boundary) {
  use acc, line <- list.fold_until(lines, [])
  case line {
    "" -> list.Stop(acc)
    line -> {
      let assert Ok(#(start, end)) = string.split_once(line, "-")
      let assert #(Ok(start), Ok(end)) = #(int.parse(start), int.parse(end))
      list.Continue([Boundary(Start, start), Boundary(End, end), ..acc])
    }
  }
}

fn compare(a: Boundary, b: Boundary) {
  case int.compare(a.value, b.value) {
    order.Eq -> case a.kind, b.kind {
      Start, End -> order.Lt
      End, Start -> order.Gt
      _, _ -> order.Eq
    }
    comp -> comp
  }
}

fn count_ids(boundaries: List(Boundary)) -> Int {
  list.fold(boundaries, #(0, 0, 0), fn (acc, boundary) {
    let #(total, diff, start) = acc
    case diff, boundary {
      0, Boundary(Start, val) -> #(total, 1, val)
      1, Boundary(End, val) -> #(total + {val - start + 1}, 0, start)
      _, Boundary(Start, _) -> #(total, diff + 1, start)
      _, Boundary(End, _) -> #(total, diff - 1, start)
    }
  }).0
}
