import gleam/io
import gleam/list.{Stop, Continue}
import gleam/pair
import gleam/set.{type Set}
import gleam/string
import simplifile

type Coord {
  Coord(row: Int, column: Int)
}

type PaperRoll {
  PaperRoll(coord: Coord)
}

type Direction {
  UpLeft
  Up
  UpRight
  Left
  Right
  DownLeft
  Down
  DownRight
}

const max_neighbors = 3

pub fn main() -> Nil{
  case simplifile.read("input.txt") {
    Ok(input) -> {
      let rolls =
        input
        |> string.trim()
        |> string.split("\n")
        |> parse_rolls()

      rolls
      |> set.filter(fn (roll) { is_accessible(roll, rolls) })
      |> set.size()
      |> echo

      Nil
    }
    Error(_) -> io.println("Error reading input.txt")
  }
}

fn parse_rolls(lines: List(String)) -> Set(PaperRoll) {
  use acc, line, row <- list.index_fold(lines, set.new())
  use acc, char, column <- list.index_fold(string.to_graphemes(line), acc)
  case char {
    "@" -> set.insert(acc, PaperRoll(coord: Coord(row: row, column: column)))
    "." -> acc
    c -> panic as { "Unexpected character in input: " <> c }
  }
}

fn is_accessible(roll: PaperRoll, rolls: Set(PaperRoll)) -> Bool {
  [UpLeft, Up, UpRight, Left, Right, DownLeft, Down, DownRight]
  |> list.fold_until(#(True, 0), fn (acc, dir) {
    let #(_, count) = acc
    let adjacent_coord = to_coord(dir, roll)
    case count, set.contains(rolls, PaperRoll(coord: adjacent_coord)) {
      count, True if count == max_neighbors -> Stop(#(False, count + 1))
      count, True -> Continue(#(True, count + 1))
      count, False -> Continue(#(True, count))
    }
  })
  |> pair.first()
}

fn to_coord(dir: Direction, roll: PaperRoll) -> Coord {
  let Coord(row, column) = roll.coord
  case dir {
    UpLeft -> Coord(row - 1, column - 1)
    Up -> Coord(row - 1, column)
    UpRight -> Coord(row - 1, column + 1)
    Left -> Coord(row, column - 1)
    Right -> Coord(row, column + 1)
    DownLeft -> Coord(row + 1, column - 1)
    Down -> Coord(row + 1, column)
    DownRight -> Coord(row + 1, column + 1)
  }
}
