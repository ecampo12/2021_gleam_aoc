import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
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
// I'm looking into gleam libraries to make memoization easier.
fn synthesize(
  rules: Dict(String, String),
  a: String,
  b: String,
  depth: Int,
  memo: Dict(#(String, String, Int), Dict(String, Int)),
) -> #(Dict(String, Int), Dict(#(String, String, Int), Dict(String, Int))) {
  case dict.has_key(memo, #(a, b, depth)) {
    True -> #(dict.get(memo, #(a, b, depth)) |> result.unwrap(dict.new()), memo)
    False ->
      case depth == 0 {
        True -> #(counter(""), memo)
        False -> {
          let x = dict.get(rules, a <> b) |> result.unwrap("")
          let left = synthesize(rules, a, x, depth - 1, memo)
          let update_memo = dict.insert(left.1, #(a, x, depth - 1), left.0)

          let right = synthesize(rules, x, b, depth - 1, update_memo)
          let update_memo2 = dict.insert(right.1, #(x, b, depth - 1), right.0)
          #(
            counter(x) |> counter_merge(left.0) |> counter_merge(right.0),
            update_memo2,
          )
        }
      }
  }
}

pub fn part1(input: String) -> Int {
  let #(template, rules) = parse(input)
  let count =
    string.to_graphemes(template)
    |> list.window_by_2
    |> list.fold(counter(template), fn(acc, pair) {
      let x = synthesize(rules, pair.0, pair.1, 10, dict.new())
      counter_merge(acc, x.0)
    })
    |> dict.values
    |> list.sort(int.compare)
  let most = list.last(count) |> result.unwrap(0)
  let least = list.first(count) |> result.unwrap(0)
  most - least
}

pub fn part2(input: String) -> Int {
  let #(template, rules) = parse(input)
  let count =
    string.to_graphemes(template)
    |> list.window_by_2
    |> list.fold(counter(template), fn(acc, pair) {
      let x = synthesize(rules, pair.0, pair.1, 40, dict.new())
      counter_merge(acc, x.0)
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
