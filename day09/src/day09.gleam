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

fn add(p1: Point, p2: Point) {
  Point(p1.row + p2.row, p1.col + p2.col)
}

fn parse(input: String) -> Dict(Point, Int) {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(acc, row, r) {
    string.to_graphemes(row)
    |> list.index_fold(acc, fn(bcc, col, c) {
      int.parse(col)
      |> result.unwrap(0)
      |> dict.insert(bcc, Point(r, c), _)
    })
  })
}

const dir = [Point(0, 1), Point(1, 0), Point(0, -1), Point(-1, 0)]

fn find_low_points(points: Dict(Point, Int)) -> List(Point) {
  dict.keys(points)
  |> list.filter(fn(p) {
    let curr = dict.get(points, p) |> result.unwrap(9)
    dir
    |> list.map(fn(d) { add(p, d) |> dict.get(points, _) |> result.unwrap(9) })
    |> list.all(fn(n) { n > curr })
  })
}

pub fn part1(input: String) -> Int {
  let points = parse(input)
  find_low_points(points)
  |> list.fold(0, fn(acc, p) {
    acc + { dict.get(points, p) |> result.unwrap(0) } + 1
  })
}

fn find_basin(
  points: Dict(Point, Int),
  start: Point,
  curr: Set(Point),
  seen: Set(Point),
) -> Set(Point) {
  case set.is_empty(curr) {
    True -> seen
    False -> {
      let new_seen = set.insert(seen, start)
      dir
      |> list.map(fn(d) { add(start, d) })
      |> list.filter(fn(n) {
        { dict.get(points, n) |> result.unwrap(9) } != 9
        && !set.contains(seen, n)
      })
      |> list.fold(new_seen, fn(acc, n) {
        set.insert(curr, n)
        |> find_basin(points, n, _, acc)
      })
    }
  }
}

pub fn part2(input: String) -> Int {
  let points = parse(input)
  find_low_points(points)
  |> list.map(fn(p) {
    set.new()
    |> set.insert(p)
    |> find_basin(points, p, _, set.new())
    |> set.size
  })
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.product
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
