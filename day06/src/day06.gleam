import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{read}

fn update(x, new: Int) {
  case x {
    Some(v) -> v + new
    None -> new
  }
}

fn reproduce(input: String, cycles: Int) -> Int {
  let fish =
    string.split(input, ",")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    |> list.group(fn(x) { x })
    |> dict.map_values(fn(_k, v) { list.length(v) })

  list.range(1, cycles)
  |> list.fold(fish, fn(acc, _x) {
    let new = dict.get(acc, 0) |> result.unwrap(0)
    acc
    |> dict.filter(fn(k, _v) { k > 0 })
    |> dict.fold(dict.new(), fn(bcc, k, v) { dict.insert(bcc, k - 1, v) })
    |> dict.upsert(6, update(_, new))
    |> dict.upsert(8, update(_, new))
  })
  |> dict.fold(0, fn(acc, _k, v) { acc + v })
}

pub fn part1(input: String) -> Int {
  reproduce(input, 80)
}

pub fn part2(input: String) -> Int {
  reproduce(input, 256)
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
