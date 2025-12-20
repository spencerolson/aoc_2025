import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Coord {
  Coord(x: Int, y: Int, z: Int)
}

pub fn main() {
  use input <- result.map(simplifile.read("input.txt"))
  let junction_boxes = input
  |> string.split("\n")
  |> list.map(fn (line) {
    let assert [x, y, z] = string.split(line, ",")
    let assert Ok(x) = int.parse(x)
    let assert Ok(y) = int.parse(y)
    let assert Ok(z) = int.parse(z)
    Coord(x, y, z)
   })
  let num_boxes = list.length(junction_boxes)

  let last_pair =
  junction_boxes
  |> pair_distances()
  |> form_circuits(num_boxes)

  last_pair.0.x * last_pair.1.x
}

fn pair_distances(coords: List(Coord)) {
  coords
  |> list.combination_pairs()
  |> list.map(fn (pair) {
    let #(coord1, coord2) = pair
    #(distance(coord1, coord2), pair)
  })
  |> list.sort(fn (a, b) {
    let #(dist_a, _) = a
    let #(dist_b, _) = b
    float.compare(dist_a, dist_b)
  })
}

fn form_circuits(pairs: List(#(Float, #(Coord, Coord))), num_boxes: Int) {
  let assert #(_, Ok(last_pair)) = list.fold_until(pairs, #([], Error(Nil)), fn (acc, pair) {
    let #(_, #(coord1, coord2)) = pair
    let #(circuits, _) = acc
    let #(occupied, rest) = list.partition(circuits, fn (circuit) {
      set.contains(circuit, coord1) || set.contains(circuit, coord2)
    })

    let new_circuits = case occupied {
      [] -> [set.new() |> set.insert(coord1) |> set.insert(coord2), ..rest]
      [a, b] -> [set.union(a, b), ..rest]
      [a] -> [set.insert(a, coord1) |> set.insert(coord2), ..rest]
      _ -> panic as "unexpected. more than two circuits occupied"
    }

    case new_circuits {
      [c] -> {
        case set.size(c) {
          n if n == num_boxes -> list.Stop(#(new_circuits, Ok(#(coord1, coord2))))
          _ -> list.Continue(#(new_circuits, Error(Nil)))
        }
      }
      _ -> list.Continue(#(new_circuits, Error(Nil)))
    }
  })
  last_pair
}

fn distance(coord1: Coord, coord2: Coord) -> Float {
  let sq_distances = squared_distance(coord1.x, coord2.x) +
    squared_distance(coord1.y, coord2.y) +
    squared_distance(coord1.z, coord2.z)

  case int.square_root(sq_distances) {
    Error(_) -> panic as "can't compute distance"
    Ok(result) -> result
  }
}

fn squared_distance(int1: Int, int2: Int) -> Int {
  case int.power(int1 - int2, 2.0) {
    Error(_) -> panic as "can't compute squared distance"
    Ok(result) -> float.truncate(result)
  }
}
