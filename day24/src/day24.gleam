import gleam/deque
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> Dict(Int, List(String)) {
  string.split(input, "\n")
  |> list.index_map(fn(x, i) { #(i, string.split(x, " ")) })
  |> dict.from_list
}

fn get_relevant_adds(
  instructions: Dict(Int, List(String)),
) -> #(List(Result(Int, Nil)), List(Result(Int, Nil))) {
  let get_b_val = fn(x: Int, offset: Int) -> String {
    let assert Ok(val) = dict.get(instructions, x + offset)
    let assert Ok(n) = list.drop(val, 2) |> list.first
    n
  }

  list.range(0, dict.size(instructions) - 1)
  |> list.index_map(fn(x, i) {
    case i % 18 == 0 {
      True -> x
      False -> -1
    }
  })
  |> list.filter(fn(x) { x != -1 })
  |> list.fold(#([], []), fn(acc, x) {
    case get_b_val(x, 4) == "1" {
      True -> {
        let num = get_b_val(x, 15) |> int.parse
        #(list.append(acc.0, [num]), list.append(acc.1, [Error(Nil)]))
      }
      False -> {
        let num = get_b_val(x, 5) |> int.parse
        #(list.append(acc.0, [Error(Nil)]), list.append(acc.1, [num]))
      }
    }
  })
}

// So our input is basically a repeat of the same sequence of 18 operations.
// What it seems to be doing is operations to registers and then some checks.
// Instead of emulating the VM we can just focus on the ops that are relevant.
// The relevant ops are the adds that are followed by a mod 26 and a div 1.
// Thsi greatly speeds up the process of finding the model numbers.
fn get_model_numbers(
  div1: List(Result(Int, Nil)),
  div2: List(Result(Int, Nil)),
) -> #(Int, Int) {
  let number1 =
    list.repeat(0, 14) |> list.index_map(fn(x, i) { #(i, x) }) |> dict.from_list
  let number2 =
    list.repeat(0, 14) |> list.index_map(fn(x, i) { #(i, x) }) |> dict.from_list
  let #(#(p1, p2), _) =
    list.zip(div1, div2)
    |> list.index_fold(#(#(number1, number2), deque.new()), fn(acc, x, i) {
      let #(#(number1, number2), stack) = acc
      let #(a, b) = x
      case a != Error(Nil) {
        True -> #(acc.0, deque.push_front(stack, #(i, a)))
        False -> {
          let assert Ok(#(#(index, a), stack)) = deque.pop_front(acc.1)
          let assert Ok(num1) = a
          let assert Ok(num2) = b
          let diff = num1 + num2
          let update_number1 =
            dict.insert(number1, index, int.min(9, 9 - diff))
            |> dict.insert(i, int.min(9, 9 + diff))
          let update_number2 =
            dict.insert(number2, index, int.max(1, 1 - diff))
            |> dict.insert(i, int.max(1, 1 + diff))
          #(#(update_number1, update_number2), stack)
        }
      }
    })
  #(
    dict.values(p1) |> int.undigits(10) |> result.unwrap(0),
    dict.values(p2) |> int.undigits(10) |> result.unwrap(0),
  )
}

pub fn part1(input: String) -> #(Int, Int) {
  let #(div1, dicv26) = parse(input) |> get_relevant_adds
  get_model_numbers(div1, dicv26)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let #(part1_ans, part2_ans) = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
