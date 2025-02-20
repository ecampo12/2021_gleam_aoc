import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/priority_queue.{type Queue} as pq
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(row: p1.row + p2.row, col: p1.col + p2.col)
}

const directions = [
  Point(row: -1, col: 0),
  Point(row: 1, col: 0),
  Point(row: 0, col: -1),
  Point(row: 0, col: 1),
]

fn parse(input: String) -> #(Dict(Point, Int), Point) {
  let rows = input |> string.split("\n")
  let height = rows |> list.length
  let width = list.first(rows) |> result.unwrap("") |> string.length

  let points =
    list.index_fold(rows, dict.new(), fn(acc, row, r) {
      string.to_graphemes(row)
      |> list.index_fold(acc, fn(bcc, col, c) {
        dict.insert(
          bcc,
          Point(row: r, col: c),
          int.parse(col) |> result.unwrap(0),
        )
      })
    })
  #(points, Point(row: height - 1, col: width - 1))
}

fn traverse(
  points: Dict(Point, Int),
  end: Point,
  queue: Queue(#(Point, Int)),
  visited: Set(Point),
) -> Int {
  case pq.pop(queue) {
    Error(_) -> 0
    Ok(#(#(point, value), new_queue)) -> {
      case point == end, set.contains(visited, point) {
        True, _ -> value
        False, True -> traverse(points, end, new_queue, visited)
        False, False -> {
          let visited = set.insert(visited, point)
          list.map(directions, fn(d) { add(point, d) })
          |> list.filter(fn(p) { dict.has_key(points, p) })
          |> list.fold(new_queue, fn(q, p) {
            let val = dict.get(points, p) |> result.unwrap(0)
            pq.push(q, #(p, value + val))
          })
          |> traverse(points, end, _, visited)
        }
      }
    }
  }
}

fn dijstra(points: Dict(Point, Int), start: Point, end: Point) -> Int {
  let queue = pq.new(fn(a: #(Point, Int), b) { int.compare(a.1, b.1) })
  let visited = set.new()
  let start_state = #(start, 0)
  let queue = pq.push(queue, start_state)
  traverse(points, end, queue, visited)
}

pub fn part1(input: String) -> Int {
  let start = Point(row: 0, col: 0)
  let #(points, end) = parse(input)
  dijstra(points, start, end)
}

// turns out the given input is just 1/5th the size of the actual map
// so we have to generate the rest of the map
fn map_expansion(input: String) -> String {
  let increment = fn(x, val) {
    case x {
      x if x + val > 9 -> x + val - 9
      _ -> x + val
    }
  }

  let first_row =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      string.to_graphemes(line)
      |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    })
    |> list.map(fn(x) {
      list.range(1, 4)
      |> list.fold(x, fn(acc, i) {
        list.map(x, fn(v) { increment(v, i) })
        |> list.append(acc, _)
      })
    })
  // I use the first "row" to generate the rest of the map
  list.range(1, 4)
  |> list.fold(first_row, fn(acc, i) {
    list.map(first_row, fn(row) { list.map(row, fn(v) { increment(v, i) }) })
    |> list.append(acc, _)
  })
  |> list.map(fn(line) {
    list.map(line, fn(x) { int.to_string(x) })
    |> string.join("")
  })
  |> string.join("\n")
}

pub fn part2(input: String) -> Int {
  let start = Point(row: 0, col: 0)
  let #(points, end) = map_expansion(input) |> parse
  dijstra(points, start, end)
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
