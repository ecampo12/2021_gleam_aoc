import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{read}

pub fn part1(input: String) -> Int {
  let #(gamma, epsilon) =
    string.split(input, "\n")
    |> list.map(string.to_graphemes)
    |> list.fold(dict.new(), fn(acc, line) {
      list.index_fold(line, acc, fn(bcc, c, i) {
        case c {
          "1" ->
            dict.upsert(bcc, i, fn(x) {
              case x {
                Some(v) -> v + 1
                None -> 1
              }
            })
          _ ->
            dict.upsert(bcc, i, fn(x) {
              case x {
                Some(v) -> v - 1
                None -> -1
              }
            })
        }
      })
    })
    |> dict.fold(#("", ""), fn(acc, _k, v) {
      case v > 0 {
        True -> #(acc.0 <> "1", acc.1 <> "0")
        False -> #(acc.0 <> "0", acc.1 <> "1")
      }
    })
  { int.base_parse(gamma, 2) |> result.unwrap(0) }
  * { int.base_parse(epsilon, 2) |> result.unwrap(0) }
}

fn rating(lines: List(Dict(Int, String)), i: Int, co2: Bool) -> String {
  case list.length(lines) == 1 {
    True -> {
      let assert Ok(rating) = lines |> list.first
      dict.fold(rating, "", fn(acc, _k, v) { acc <> v })
    }
    False -> {
      let ones = list.filter(lines, fn(x) { dict.get(x, i) == Ok("1") })
      let zeros = list.filter(lines, fn(x) { dict.get(x, i) == Ok("0") })
      case co2 {
        True -> {
          case list.length(ones) < list.length(zeros) {
            True -> rating(ones, i + 1, co2)
            False -> rating(zeros, i + 1, co2)
          }
        }
        False -> {
          case list.length(ones) >= list.length(zeros) {
            True -> rating(ones, i + 1, co2)
            False -> rating(zeros, i + 1, co2)
          }
        }
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  let parsed =
    string.split(input, "\n")
    |> list.map(fn(x) {
      string.to_graphemes(x)
      |> list.index_map(fn(x, i) { #(i, x) })
      |> dict.from_list
    })
  let assert Ok(o2) = rating(parsed, 0, False) |> int.base_parse(2)
  let assert Ok(co2) = rating(parsed, 0, True) |> int.base_parse(2)
  o2 * co2
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
