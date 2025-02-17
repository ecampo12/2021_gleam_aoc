import gleam/deque.{pop_front, push_front}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{unwrap}
import gleam/string
import simplifile.{read}

fn check_line(line: String) -> Int {
  let scores =
    [#(")", 3), #("]", 57), #("}", 1197), #(">", 25_137)]
    |> dict.from_list
  let compliments =
    [#(")", "("), #("]", "["), #("}", "{"), #(">", "<")]
    |> dict.from_list
  let #(num, _) =
    string.to_graphemes(line)
    |> list.fold_until(#(0, deque.new()), fn(acc, s) {
      let #(score, stack) = acc
      case s {
        "(" | "[" | "{" | "<" -> list.Continue(#(score, push_front(stack, s)))
        ")" | "]" | "}" | ">" -> {
          let comp = dict.get(compliments, s) |> unwrap("")
          let c = { pop_front(stack) |> unwrap(#("", deque.new())) }.0
          case comp == c {
            True -> {
              let new_stack =
                { pop_front(stack) |> unwrap(#("", deque.new())) }.1
              list.Continue(#(score, new_stack))
            }
            False -> {
              let score = dict.get(scores, s) |> unwrap(0)
              list.Stop(#(score, stack))
            }
          }
        }
        _ -> list.Continue(acc)
      }
    })
  num
}

pub fn part1(input: String) -> Int {
  input |> string.split("\n") |> list.map(check_line) |> int.sum
}

fn complete_line(line: String) -> List(String) {
  let compliments =
    [#("(", ")"), #("[", "]"), #("{", "}"), #("<", ">")]
    |> dict.from_list
  string.to_graphemes(line)
  |> list.fold(deque.new(), fn(acc, s) {
    case s {
      "(" | "[" | "{" | "<" -> push_front(acc, s)
      _ -> { pop_front(acc) |> unwrap(#("", deque.new())) }.1
    }
  })
  |> deque.to_list
  |> list.map(fn(s) { dict.get(compliments, s) |> unwrap("") })
}

pub fn part2(input: String) -> Int {
  let points =
    [#(")", 1), #("]", 2), #("}", 3), #(">", 4)]
    |> dict.from_list
  let scores =
    input
    |> string.split("\n")
    |> list.filter(fn(x) { check_line(x) == 0 })
    |> list.map(fn(x) {
      complete_line(x)
      |> list.fold(0, fn(acc, x) {
        { acc * 5 } + { dict.get(points, x) |> unwrap(0) }
      })
    })
    |> list.sort(int.compare)
  let mid_index = { list.length(scores) - 1 } / 2
  list.drop(scores, mid_index) |> list.first |> unwrap(0)
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
