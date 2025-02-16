import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn fuel_total(input: String, fuel_calc: fn(Int) -> Int) -> Int {
  let nums =
    string.split(input, ",")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    |> list.sort(int.compare)

  list.range(0, { list.last(nums) |> result.unwrap(0) } + 1)
  |> list.map(fn(level) {
    list.fold(nums, 0, fn(acc, x) {
      let n = int.absolute_value(level - x)
      acc + fuel_calc(n)
    })
  })
  |> list.sort(int.compare)
  |> list.first
  |> result.unwrap(0)
}

pub fn part1(input: String) -> Int {
  fuel_total(input, fn(n) { n })
}

pub fn part2(input: String) -> Int {
  fuel_total(input, fn(n) { n * { n + 1 } / 2 })
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
