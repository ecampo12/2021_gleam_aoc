import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(row: p1.row + p2.row, col: p1.col + p2.col)
}

fn parse(input: String) -> Dict(Point, String) {
  string.split(input, "\n")
  |> list.index_map(fn(row, r) {
    string.to_graphemes(row)
    |> list.index_map(fn(col, c) { #(Point(row: r, col: c), col) })
  })
  |> list.flatten
  |> dict.from_list
}

fn can_move(input: Dict(Point, String), point: Point, value: String) -> Bool {
  case value {
    ">" -> {
      let next = add(point, Point(row: 0, col: 1))
      case dict.has_key(input, next) {
        True -> dict.get(input, next) == Ok(".")
        False -> Point(..next, col: 0) |> dict.get(input, _) == Ok(".")
      }
    }
    "v" -> {
      let next = add(point, Point(row: 1, col: 0))
      case dict.has_key(input, next) {
        True -> dict.get(input, next) == Ok(".")
        False -> Point(..next, row: 0) |> dict.get(input, _) == Ok(".")
      }
    }
    "." | _ -> False
  }
}

// kind of slow, which makes sense. We traverse the map multiple times per move.
fn cucumber_moves(
  input: Dict(Point, String),
  has_moved: Bool,
  count: Int,
) -> Int {
  case has_moved {
    False -> count
    True -> {
      let east =
        dict.filter(input, fn(_, v) { v == ">" })
        |> dict.filter(fn(k, _) { can_move(input, k, ">") })
        // we find which came move first, then we move it.
        |> dict.fold(input, fn(acc, point, _) {
          let next = add(point, Point(row: 0, col: 1))
          let spot = case dict.has_key(acc, next) {
            True -> next
            False -> Point(..next, col: 0)
          }
          dict.insert(acc, point, ".")
          |> dict.insert(spot, ">")
        })

      let south =
        dict.filter(east, fn(_, v) { v == "v" })
        |> dict.filter(fn(k, _) { can_move(east, k, "v") })
        |> dict.fold(east, fn(acc, point, _) {
          let next = add(point, Point(row: 1, col: 0))
          let spot = case dict.has_key(acc, next) {
            True -> next
            False -> Point(..next, row: 0)
          }
          dict.insert(acc, point, ".")
          |> dict.insert(spot, "v")
        })

      cucumber_moves(south, south != input, count + 1)
    }
  }
}

pub fn part1(input: String) -> Int {
  parse(input) |> cucumber_moves(True, 0)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
}
