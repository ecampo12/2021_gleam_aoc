import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type Point {
  Point(x: Int, y: Int)
}

fn parse(input: String) -> #(Set(Point), List(#(String, Int))) {
  let parts = string.split(input, "\n\n")
  let points =
    string.split(list.first(parts) |> result.unwrap(""), "\n")
    |> list.fold(set.new(), fn(acc, line) {
      let parts = string.split(line, ",")
      Point(
        int.parse(list.first(parts) |> result.unwrap("")) |> result.unwrap(0),
        int.parse(list.last(parts) |> result.unwrap("")) |> result.unwrap(0),
      )
      |> set.insert(acc, _)
    })
  let instructions =
    string.split(list.last(parts) |> result.unwrap(""), "\n")
    |> list.map(fn(line) {
      let inst =
        string.split(line, " ")
        |> list.last
        |> result.unwrap("")
        |> string.split("=")
      #(
        list.first(inst) |> result.unwrap(""),
        int.parse(list.last(inst) |> result.unwrap("")) |> result.unwrap(0),
      )
    })
  #(points, instructions)
}

fn fold(points: Set(Point), instruction: #(String, Int)) -> Set(Point) {
  let #(axis, value) = instruction
  set.fold(points, set.new(), fn(acc, point) {
    let #(x, y) = #(point.x, point.y)
    case axis {
      "x" if x > value -> {
        Point(value - { x - value }, y)
      }
      "y" if y > value -> {
        Point(x, value - { y - value })
      }
      _ -> point
    }
    |> set.insert(acc, _)
  })
}

pub fn part1(input: String) -> Int {
  let #(points, instructions) = parse(input)
  list.first(instructions)
  |> result.unwrap(#("", 0))
  |> fold(points, _)
  |> set.size
}

fn max(points: Set(Int)) -> Int {
  set.to_list(points)
  |> list.sort(int.compare)
  |> list.last
  |> result.unwrap(0)
}

pub fn part2(input: String) -> String {
  let #(points, instructions) = parse(input)
  let final =
    list.fold(instructions, points, fn(acc, instruction) {
      fold(acc, instruction)
    })
  let dim_x = set.map(final, fn(p) { p.x }) |> max
  let dim_y = set.map(final, fn(p) { p.y }) |> max
  list.range(0, dim_y)
  |> list.index_fold("", fn(acc, _a, y) {
    list.range(0, dim_x)
    |> list.index_fold(acc, fn(bcc, _b, x) {
      case set.contains(final, Point(x, y)) {
        True -> bcc <> "#"
        False -> bcc <> " "
      }
    })
    <> "\n"
  })
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.println("Part 2: ")
  io.println(part2_ans)
}
