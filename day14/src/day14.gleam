import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import rememo/memo
import simplifile.{read}

fn parse(input: String) -> #(String, Dict(String, String)) {
  case string.split(input, "\n") {
    [template, _, ..rules] -> {
      let r =
        list.map(rules, fn(rule) {
          case string.split(rule, " ") {
            [a, "->", b] -> #(a, b)
            _ -> #("", "")
          }
        })
        |> dict.from_list
      #(template, r)
    }
    _ -> #(input, dict.new())
  }
}

fn counter(s: String) -> Dict(String, Int) {
  string.to_graphemes(s)
  |> list.group(fn(x) { x })
  |> dict.map_values(fn(_k, v) { list.length(v) })
}

fn counter_merge(
  a: Dict(String, Int),
  b: Dict(String, Int),
) -> Dict(String, Int) {
  dict.fold(a, b, fn(acc, k, v) {
    dict.upsert(acc, k, fn(x) {
      case x {
        Some(n) -> n + v
        None -> v
      }
    })
  })
}

// needed to add memoization to greatly speed up the solution.
// rememo is a Gleam library that provides a simple API for memoization.
// Its way faster and simpler than my previous solution.
fn synthesize(
  rules: Dict(String, String),
  a: String,
  b: String,
  depth: Int,
  cache,
) -> Dict(String, Int) {
  use <- memo.memoize(cache, #(a, b, depth))
  case depth == 0 {
    True -> counter("")
    False -> {
      let x = dict.get(rules, a <> b) |> result.unwrap("")
      counter(x)
      |> counter_merge(synthesize(rules, a, x, depth - 1, cache))
      |> counter_merge(synthesize(rules, x, b, depth - 1, cache))
    }
  }
}

pub fn part1(input: String) -> Int {
  use cache <- memo.create()
  let #(template, rules) = parse(input)
  let count =
    string.to_graphemes(template)
    |> list.window_by_2
    |> list.fold(counter(template), fn(acc, pair) {
      synthesize(rules, pair.0, pair.1, 10, cache)
      |> counter_merge(acc)
    })
    |> dict.values
    |> list.sort(int.compare)
  let most = list.last(count) |> result.unwrap(0)
  let least = list.first(count) |> result.unwrap(0)
  most - least
}

pub fn part2(input: String) -> Int {
  use cache <- memo.create()
  let #(template, rules) = parse(input)
  let count =
    string.to_graphemes(template)
    |> list.window_by_2
    |> list.fold(counter(template), fn(acc, pair) {
      synthesize(rules, pair.0, pair.1, 40, cache)
      |> counter_merge(acc)
    })
    |> dict.values
    |> list.sort(int.compare)
  let most = list.last(count) |> result.unwrap(0)
  let least = list.first(count) |> result.unwrap(0)
  most - least
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
