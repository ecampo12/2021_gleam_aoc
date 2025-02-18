import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.row + p2.row, p1.col + p2.col)
}

fn in_bounds(p: Point) -> Bool {
  p.row >= 0 && p.row < 10 && p.col >= 0 && p.col < 10
}

const adjacent_offsets = [
  Point(-1, -1),
  Point(-1, 0),
  Point(-1, 1),
  Point(0, -1),
  Point(0, 1),
  Point(1, -1),
  Point(1, 0),
  Point(1, 1),
]

fn parse(input: String) -> Dict(Point, Int) {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(acc, row, r) {
    string.to_graphemes(row)
    |> list.index_fold(acc, fn(bcc, col, c) {
      int.parse(col)
      |> result.unwrap(-1)
      |> dict.insert(bcc, Point(r, c), _)
    })
  })
}

fn flash(
  octopuses: Dict(Point, Int),
  flashed: Set(Point),
  curr: Point,
) -> #(Dict(Point, Int), Set(Point)) {
  case set.contains(flashed, curr) {
    True -> {
      #(dict.insert(octopuses, curr, 0), flashed)
    }
    False -> {
      case dict.get(octopuses, curr) {
        Ok(x) if x > 9 -> {
          let octopuses = dict.insert(octopuses, curr, 0)
          let flashed = set.insert(flashed, curr)
          adjacent_offsets
          |> list.fold(#(octopuses, flashed), fn(acc, offset) {
            let adj = add(curr, offset)
            let val = dict.get(acc.0, adj) |> result.unwrap(0)
            case in_bounds(adj) {
              True -> flash(dict.insert(acc.0, adj, val + 1), acc.1, adj)
              False -> acc
            }
          })
        }
        _ -> #(octopuses, flashed)
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let octopuses = parse(input)
  {
    list.range(1, 100)
    |> list.fold(#(octopuses, 0), fn(acc, _x) {
      let updated = dict.map_values(acc.0, fn(_k, v) { v + 1 })
      let flashers = dict.filter(updated, fn(_k, v) { v > 9 })
      let #(octopuses, flashed) =
        dict.fold(flashers, #(updated, set.new()), fn(acc, k, _v) {
          flash(acc.0, acc.1, k)
        })

      #(octopuses, acc.1 + set.size(flashed))
    })
  }.1
}

fn count_flashes(octopuses: Dict(Point, Int), count: Int) -> Int {
  let updated = dict.map_values(octopuses, fn(_k, v) { v + 1 })
  let flashers = dict.filter(updated, fn(_k, v) { v > 9 })
  let #(octopuses, _) =
    dict.fold(flashers, #(updated, set.new()), fn(acc, k, _v) {
      flash(acc.0, acc.1, k)
    })
  case dict.filter(octopuses, fn(_k, v) { v == 0 }) |> dict.size == 100 {
    True -> count
    False -> count_flashes(octopuses, count + 1)
  }
}

pub fn part2(input: String) -> Int {
  count_flashes(parse(input), 1)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
