import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

type Board {
  Board(points: Dict(String, Point), marked: Set(Point))
}

fn new() -> Board {
  Board(dict.new(), set.new())
}

fn parse(input: String) -> #(List(String), List(Board)) {
  let assert Ok(re) = regexp.from_string("\\d+")
  let parsed =
    input
    |> string.split("\n\n")
  let numbers =
    list.first(parsed)
    |> result.unwrap("")
    |> string.split(",")

  let boards =
    list.drop(parsed, 1)
    |> list.map(fn(board) {
      let points =
        string.split(board, "\n")
        |> list.index_map(fn(row, r) {
          regexp.scan(re, row)
          |> list.index_map(fn(col, c) { #(col.content, Point(r, c)) })
        })
        |> list.flatten
        |> dict.from_list
      Board(points, set.new())
    })
  #(numbers, boards)
}

fn mark(b: Board, num: String) -> Board {
  let point = dict.get(b.points, num)
  case point {
    Error(_) -> b
    Ok(p) -> Board(b.points, set.insert(b.marked, p))
  }
}

fn check(b: Board) -> Bool {
  // check rows
  list.range(0, 4)
  |> list.any(fn(x) {
    set.filter(b.marked, fn(p) { p.row == x }) |> set.size == 5
  })
  // check cols
  || list.range(0, 4)
  |> list.any(fn(x) {
    set.filter(b.marked, fn(p) { p.col == x }) |> set.size == 5
  })
}

pub fn part1(input: String) -> Int {
  let #(numbers, boards) = parse(input)
  let #(num, winner, _) =
    list.fold_until(
      numbers,
      #("", Board(dict.new(), set.new()), boards),
      fn(acc, num) {
        let updated_borads = list.map(acc.2, fn(board) { mark(board, num) })
        case list.filter(updated_borads, check) |> list.first {
          Error(_) -> list.Continue(#(acc.0, acc.1, updated_borads))
          Ok(b) -> list.Stop(#(num, b, updated_borads))
        }
      },
    )
  let unmarked_sum =
    dict.to_list(winner.points)
    |> list.filter(fn(p) { !set.contains(winner.marked, p.1) })
    |> list.map(fn(p) { p.0 |> int.parse |> result.unwrap(0) })
    |> int.sum
  unmarked_sum * { num |> int.parse |> result.unwrap(0) }
}

pub fn part2(input: String) -> Int {
  let #(numbers, boards) = parse(input)
  let #(num, winner) =
    list.fold_until(numbers, #("", boards), fn(acc, num) {
      let updated_borads = list.map(acc.1, fn(board) { mark(board, num) })
      case list.length(updated_borads) {
        1 -> {
          let b = list.first(updated_borads) |> result.unwrap(new())
          case check(b) {
            True -> list.Stop(#(num, updated_borads))
            False -> list.Continue(#(acc.0, updated_borads))
          }
          list.Stop(#(num, updated_borads))
        }
        _ ->
          list.Continue(#(
            acc.0,
            updated_borads |> list.filter(fn(board) { !check(board) }),
          ))
      }
    })
  let board = list.first(winner) |> result.unwrap(new())
  let unmarked_sum =
    dict.to_list(board.points)
    |> list.filter(fn(p) { !set.contains(board.marked, p.1) })
    |> list.map(fn(p) { p.0 |> int.parse |> result.unwrap(0) })
    |> int.sum
  unmarked_sum * { num |> int.parse |> result.unwrap(0) }
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
