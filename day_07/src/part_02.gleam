// import gleam/int
import gleam/dict
import gleam/list
import gleam/result
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
  do_count_beam_splits(grid, entry, dict.new()).0
}

fn do_count_beam_splits(grid: types.Grid, cell: types.Cell, cache: dict.Dict(types.Coord, Int)) {
  case dict.get(cache, cell.coord) {
    Ok(cached_count) -> #(cached_count, cache)
    Error(Nil) -> {
      case cell.kind {
        types.Splitter -> count_from_splitter(grid, cell, cache)
        _ -> count_from_empty_space(grid, cell, cache)
      }
    }
  }
}

fn count_from_splitter(grid: types.Grid, cell: types.Cell, cache: dict.Dict(types.Coord, Int)) {
  let assert Ok(left_cell) = dict.get(grid, types.Coord(cell.coord.x - 1, cell.coord.y))
  let assert Ok(right_cell) = dict.get(grid, types.Coord(cell.coord.x + 1, cell.coord.y))
  let #(left_count, left_cache) = do_count_beam_splits(grid, left_cell, cache)
  let #(right_count, combined_cache) = do_count_beam_splits(grid, right_cell, left_cache)
  #(
    left_count + right_count,
    dict.insert(combined_cache, cell.coord, left_count + right_count)
  )
}

fn count_from_empty_space(grid: types.Grid, cell: types.Cell, cache: dict.Dict(types.Coord, Int)) {
  let down_coord = types.Coord(cell.coord.x, cell.coord.y + 1)
  case dict.get(grid, down_coord) {
    Ok(down_cell) -> do_count_beam_splits(grid, down_cell, cache)
    Error(Nil) -> #(1, cache) // reached the bottom of the grid
  }
}