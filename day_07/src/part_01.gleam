import gleam/dict
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile
import types

pub fn main() {
  use input <- result.try(read_input())
  let #(grid, entry_result) = parse_grid(input)
  case entry_result {
    Ok(entry) -> Ok(count_beam_splits(grid, entry))
    _ -> Error(types.MissingEntryCell)
  }
}

fn read_input() {
  "input.txt"
  |> simplifile.read()
  |> result.replace_error(types.InvalidInput)
}

fn parse_grid(input: String) {
  let lines = string.split(input, "\n")
  use acc, line, y <- list.index_fold(lines, #(dict.new(), Error(types.MissingEntryCell)))
  use #(grid, entry), char, x <- list.index_fold(string.to_graphemes(line), acc)
  let cell = types.Cell(coord: types.Coord(x, y), kind: kind(char))
  let entry = case cell.kind {
    types.BeamEntryPoint -> Ok(cell)
    _ -> entry
  }
  #(dict.insert(grid, cell.coord, cell), entry)
}

fn kind(char: String) {
  case char {
    "S" -> types.BeamEntryPoint
    "." -> types.EmptySpace
    "^" -> types.Splitter
    c -> panic as { "Unknown char: " <> c }
  }
}

fn count_beam_splits(grid: types.Grid, entry: types.Cell) {
  do_count_beam_splits(grid, [entry], set.new(), 0)
}

fn do_count_beam_splits(grid: types.Grid, to_visit: List(types.Cell), visited: set.Set(types.Cell), count: Int) {
  case to_visit {
    [] -> count
    [cell, ..rest_to_visit] -> {
      let #(dir, new_count) = case cell.kind {
        types.Splitter -> #(types.Sideways, count + 1)
        _ -> #(types.Down, count)
      }
      do_count_beam_splits(
        grid,
        add_unvisited_neighbors(dir, grid, rest_to_visit, visited, cell),
        set.insert(visited, cell),
        new_count
      )
    }
  }
}

fn add_unvisited_neighbors(direction: types.Direction, grid: types.Grid, to_visit: List(types.Cell), visited: set.Set(types.Cell), cell: types.Cell) {
  let neighbors = case direction {
    types.Down -> [dict.get(grid, types.Coord(cell.coord.x, cell.coord.y + 1))]
    types.Sideways -> [
      dict.get(grid, types.Coord(cell.coord.x - 1, cell.coord.y)),
      dict.get(grid, types.Coord(cell.coord.x + 1, cell.coord.y))
    ]
  }

  neighbors
  |> result.values() // filter out out-of-bounds cells
  |> list.fold(to_visit, fn (acc, n) {
    case set.contains(visited, n) {
      True -> acc
      False ->  [n, ..acc]
    }
  })
}