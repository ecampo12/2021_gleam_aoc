import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{read}

type Point {
  Point(x: Int, y: Int)
}

fn new() -> Point {
  Point(-1, -1)
}

fn parse(input: String) -> List(#(Point, Point)) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let points =
      string.split(line, " -> ")
      |> list.map(fn(p) {
        case string.split(p, ",") {
          [x, y] ->
            Point(
              int.parse(x) |> result.unwrap(-1),
              int.parse(y) |> result.unwrap(-1),
            )
          _ -> new()
        }
      })
    #(
      list.first(points) |> result.unwrap(new()),
      list.last(points) |> result.unwrap(new()),
    )
  })
}

fn points_between(p1: Point, p2: Point) -> List(Point) {
  case p1.x == p2.x {
    True -> list.range(p1.y, p2.y) |> list.map(fn(y) { Point(p1.x, y) })
    False -> list.range(p1.x, p2.x) |> list.map(fn(x) { Point(x, p1.y) })
  }
}

fn increment(x) -> Int {
  case x {
    Some(v) -> v + 1
    None -> 1
  }
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> list.filter(fn(line) {
    { line.0 }.x == { line.1 }.x || { line.0 }.y == { line.1 }.y
  })
  |> list.fold(dict.new(), fn(acc, line) {
    points_between(line.0, line.1)
    |> list.fold(acc, fn(bcc, p) { dict.upsert(bcc, p, increment) })
  })
  |> dict.filter(fn(_k, v) { v > 1 })
  |> dict.size()
}

fn point_between_diagonal(p1: Point, p2: Point) -> List(Point) {
  list.range(p1.x, p2.x)
  |> list.zip(list.range(p1.y, p2.y))
  |> list.map(fn(p) { Point(p.0, p.1) })
}

pub fn part2(input: String) -> Int {
  parse(input)
  |> list.fold(dict.new(), fn(acc, line) {
    case { line.0 }.x == { line.1 }.x || { line.0 }.y == { line.1 }.y {
      True -> points_between(line.0, line.1)
      False -> point_between_diagonal(line.0, line.1)
    }
    |> list.fold(acc, fn(bcc, p) { dict.upsert(bcc, p, increment) })
  })
  |> dict.filter(fn(_k, v) { v > 1 })
  |> dict.size()
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
