import gleam/float
import gleam/int
import gleam/order
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
  input
  |> string.split("\n")
  |> list.map(fn (line) {
    let assert [x, y, z] = string.split(line, ",")
    let assert Ok(x) = int.parse(x)
    let assert Ok(y) = int.parse(y)
    let assert Ok(z) = int.parse(z)
    Coord(x, y, z)
   })
  |> pair_distances()
  |> form_circuits()
  |> mult_3_largest()
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

fn form_circuits(pairs: List(#(Float, #(Coord, Coord)))) {
  list.fold_until(pairs, #([], 1000), fn (acc, pair) {
    let #(_, #(coord1, coord2)) = pair
    let #(circuits, connections_left) = acc
    case connections_left {
      0 -> list.Stop(acc)
      _ -> {
        let #(occupied, rest) = list.partition(circuits, fn (circuit) {
          set.contains(circuit, coord1) || set.contains(circuit, coord2)
        })

        let new_circuits = case occupied {
          [] -> [set.new() |> set.insert(coord1) |> set.insert(coord2), ..rest]
          [a, b] -> [set.union(a, b), ..rest]
          [a] -> [set.insert(a, coord1) |> set.insert(coord2), ..rest]
          _ -> panic as "unexpected. more than two circuits occupied"
        }

        list.Continue(#(new_circuits, connections_left - 1))
      }
    }
  }).0
}

fn mult_3_largest(circuits: List(set.Set(Coord))) {
  circuits
  |> list.map(set.size)
  |> list.sort(order.reverse(int.compare))
  |> list.take(3)
  |> int.product()
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
