import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> List(Int) {
  string.split(input, "\n")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
}

pub fn part1(input: String) -> Int {
  let nums = parse(input)
  list.zip(nums, list.drop(nums, 1))
  |> list.filter(fn(x) { x.0 < x.1 })
  |> list.length
}

pub fn part2(input: String) -> Int {
  let nums = parse(input)
  let windowed = list.window(nums, 3) |> list.map(fn(x) { int.sum(x) })
  list.zip(windowed, list.drop(windowed, 1))
  |> list.filter(fn(x) { x.0 < x.1 })
  |> list.length
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
