import gleam/dict.{type Dict}

pub type GridError {
  InvalidInput
  MissingEntryCell
}

pub type Direction {
  Down
  Sideways
}

pub type Kind {
  BeamEntryPoint
  EmptySpace
  Splitter
}

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type Cell {
  Cell(coord: Coord, kind: Kind)
}

pub type Grid = Dict(Coord, Cell)