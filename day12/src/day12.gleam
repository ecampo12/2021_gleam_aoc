import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

fn update(x, end) {
  case x {
    Some(v) -> [end, ..v]
    None -> [end]
  }
}

fn build_graph(input: String) -> Dict(String, List(String)) {
  string.split(input, "\n")
  |> list.fold(dict.new(), fn(acc, line) {
    let parts = string.split(line, "-")
    let start = list.first(parts) |> result.unwrap("")
    let end = list.last(parts) |> result.unwrap("")
    dict.upsert(acc, start, fn(x) { update(x, end) })
    |> dict.upsert(end, fn(x) { update(x, start) })
  })
}

fn is_lower_case(str: String) -> Bool {
  string.lowercase(str) == str
}

fn traverse(
  graph: Dict(String, List(String)),
  node: String,
  small_caves: Set(String),
  trail: List(String),
  all_trails: Set(List(String)),
) -> Set(List(String)) {
  case node {
    "end" -> set.insert(all_trails, trail)
    _ -> {
      let next_nodes = dict.get(graph, node) |> result.unwrap([])
      list.fold(next_nodes, all_trails, fn(acc, next_node) {
        case set.contains(small_caves, next_node) {
          True -> acc
          False -> {
            let next_trail = [next_node, ..trail]
            let update_caves = case is_lower_case(next_node) {
              True -> set.insert(small_caves, next_node)
              False -> small_caves
            }
            traverse(graph, next_node, update_caves, next_trail, acc)
          }
        }
      })
    }
  }
}

pub fn part1(input: String) -> Int {
  build_graph(input)
  |> traverse("start", set.new() |> set.insert("start"), ["start"], set.new())
  |> set.to_list
  |> list.length
}

pub fn part2(input: String) -> Int {
  todo
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
