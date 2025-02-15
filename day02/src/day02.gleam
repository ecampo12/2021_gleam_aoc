import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

type Position {
  Position(horizontal: Int, depth: Int, aim: Int)
}

fn parse(input: String, part2: Bool) -> List(fn(Position) -> Position) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let parsed = string.split(line, " ")
    let assert Ok(direction) = list.first(parsed)
    let distance =
      list.last(parsed) |> result.unwrap("") |> int.parse |> result.unwrap(0)
    case direction, part2 {
      "forward", False -> fn(p: Position) {
        Position(..p, horizontal: p.horizontal + distance)
      }
      "down", False -> fn(p: Position) {
        Position(..p, depth: p.depth + distance)
      }
      "up", False -> fn(p: Position) {
        Position(..p, depth: p.depth - distance)
      }
      "forward", True -> fn(p: Position) {
        Position(
          ..p,
          horizontal: p.horizontal + distance,
          depth: p.depth + { p.aim * distance },
        )
      }
      "down", True -> fn(p: Position) { Position(..p, aim: p.aim + distance) }
      "up", True -> fn(p: Position) { Position(..p, aim: p.aim - distance) }
      _, _ -> fn(pos) { pos }
    }
  })
}

pub fn part1(input: String) -> Int {
  let course = parse(input, False)
  let final_position = list.fold(course, Position(0, 0, 0), fn(p, f) { f(p) })
  final_position.horizontal * final_position.depth
}

pub fn part2(input: String) -> Int {
  let course = parse(input, True)
  let final_position = list.fold(course, Position(0, 0, 0), fn(p, f) { f(p) })
  final_position.horizontal * final_position.depth
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
