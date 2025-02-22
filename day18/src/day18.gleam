import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

// Had a couple of choices for the data structure here. I could have raw dogged the string, which would've been crazy.
// I could've used a tree structure, which might've made explode and split easier to implement, but I went with a list of list of tuples.
// It was eaier to parse, it would've been easier to implement the explode ans split functions if gleam had a built-in way to index into a list.
pub fn parse(input: String) -> List(List(#(Int, Int))) {
  string.split(input, "\n")
  |> list.fold([], fn(acc, line) {
    [
      {
        string.to_graphemes(line)
        |> list.fold(#([], 0), fn(bcc, x) {
          case x {
            "[" -> #(bcc.0, bcc.1 + 1)
            "]" -> #(bcc.0, bcc.1 - 1)
            _ ->
              case int.parse(x) {
                Ok(n) -> #(list.append(bcc.0, [#(n, bcc.1)]), bcc.1)
                Error(_) -> bcc
              }
          }
        })
      }.0,
    ]
    |> list.append(acc, _)
  })
}

pub fn explode(x: List(#(Int, Int))) -> #(Bool, List(#(Int, Int))) {
  list.zip(x, list.drop(x, 1))
  |> list.index_map(fn(pair, i) { #(pair.0, pair.1, i) })
  |> list.fold_until(#(False, x), fn(acc, pair) {
    let #(#(num1, depth1), #(num2, depth2), i) = pair
    case depth1 < 5 || depth1 != depth2 {
      True -> list.Continue(acc)
      False -> {
        let indexed =
          list.index_map(acc.1, fn(x, i) { #(i, x) }) |> dict.from_list
        let a = dict.get(indexed, i - 1) |> result.unwrap(#(0, 0))
        let b = dict.get(indexed, i + 2) |> result.unwrap(#(0, 0))
        let val1 = #(a.0 + num1, a.1)
        let val2 = #(b.0 + num2, b.1)
        let x = case i > 0, i < list.length(x) - 2 {
          True, True -> {
            dict.insert(indexed, i - 1, val1)
            |> dict.insert(i + 2, val2)
            |> dict.values
          }
          True, False -> {
            dict.insert(indexed, i - 1, val1)
            |> dict.values
          }
          False, True -> {
            dict.insert(indexed, i + 2, val2)
            |> dict.values
          }
          False, False -> acc.1
        }
        let update =
          list.append(list.take(x, i), [#(0, depth1 - 1)])
          |> list.append(list.drop(x, i + 2))
        list.Stop(#(True, update))
      }
    }
  })
}

pub fn split(x: List(#(Int, Int))) -> #(Bool, List(#(Int, Int))) {
  list.index_map(x, fn(pair, i) { #(pair.0, pair.1, i) })
  |> list.fold_until(#(False, x), fn(acc, pair) {
    let #(num, depth, i) = pair
    case num < 10 {
      True -> list.Continue(acc)
      False -> {
        let down = num / 2
        let up = num - down
        list.Stop(#(
          True,
          list.append(list.take(x, i), [#(down, depth + 1), #(up, depth + 1)])
            |> list.append(list.drop(x, i + 1)),
        ))
      }
    }
  })
}

fn add(a: List(#(Int, Int)), b: List(#(Int, Int))) -> List(#(Int, Int)) {
  list.append(a, b)
  |> list.map(fn(x) { #(x.0, x.1 + 1) })
  |> do_add(True, _)
}

fn do_add(cond: Bool, x: List(#(Int, Int))) -> List(#(Int, Int)) {
  case cond {
    False -> x
    True -> {
      let #(change, x) = explode(x)
      case change {
        True -> do_add(True, x)
        False -> {
          let #(change, x) = split(x)
          case change {
            True -> do_add(True, x)
            False -> x
          }
        }
      }
    }
  }
}

pub fn magnitude(x: List(#(Int, Int))) -> Int {
  case list.length(x) > 1 {
    False -> { list.first(x) |> result.unwrap(#(0, 0)) }.0
    True -> {
      list.zip(x, list.drop(x, 1))
      |> list.index_map(fn(pair, i) { #(pair.0, pair.1, i) })
      |> list.fold_until(0, fn(acc, pair) {
        case pair.0.1 == pair.1.1 {
          False -> list.Continue(acc)
          True -> {
            let val = pair.0.0 * 3 + pair.1.0 * 2
            let a = list.take(x, pair.2)
            let b = list.drop(x, pair.2 + 2)
            list.append(a, [#(val, pair.0.1 - 1)])
            |> list.append(b)
            |> magnitude
            |> list.Stop
          }
        }
      })
    }
  }
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> list.reduce(fn(acc, x) { add(acc, x) })
  |> result.unwrap([])
  |> magnitude
}

fn snail_sums(x: List(List(#(Int, Int)))) -> List(Int) {
  list.index_map(x, fn(a, i) {
    list.index_map(x, fn(b, j) {
      case i != j {
        True -> add(a, b) |> magnitude
        False -> 0
      }
    })
  })
  |> list.flatten
}

pub fn part2(input: String) -> Int {
  parse(input)
  |> snail_sums
  |> list.max(int.compare)
  |> result.unwrap(0)
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
