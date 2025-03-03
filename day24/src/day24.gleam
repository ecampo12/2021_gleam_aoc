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
  list.range(0, dict.size(instructions) - 1)
  |> list.index_map(fn(x, i) {
    case i % 18 == 0 {
      True -> x
      False -> -1
    }
  })
  |> list.filter(fn(x) { x != -1 })
  |> list.fold(#([], []), fn(acc, x) {
    let assert Ok(val) = dict.get(instructions, x + 4)
    case list.drop(val, 2) |> list.first == Ok("1") {
      True -> {
        let assert Ok(val) = dict.get(instructions, x + 15)
        let assert Ok(n) = list.drop(val, 2) |> list.first
        let num = int.parse(n)
        #(list.append(acc.0, [num]), list.append(acc.1, [Error(Nil)]))
        // acc
      }
      False -> {
        let assert Ok(val) = dict.get(instructions, x + 5)
        let assert Ok(n) = list.drop(val, 2) |> list.first
        let num = int.parse(n)
        #(list.append(acc.0, [Error(Nil)]), list.append(acc.1, [num]))
        // acc
      }
    }
    // acc
  })
  // #([], [])
}

fn get_model_number(
  div1: List(Result(Int, Nil)),
  div2: List(Result(Int, Nil)),
) -> List(Int) {
  let number =
    list.repeat(0, 14) |> list.index_map(fn(x, i) { #(i, x) }) |> dict.from_list
  let #(res, _) =
    list.zip(div1, div2)
    |> list.index_fold(#(number, deque.new()), fn(acc, x, i) {
      let #(num, stack) = acc
      let #(a, b) = x
      case a != Error(Nil) {
        True -> {
          io.debug(#(i, a))
          #(acc.0, deque.push_front(stack, #(i, a)))
        }
        False -> {
          let assert Ok(#(#(index, a), stack)) = deque.pop_front(acc.1)
          let assert Ok(num1) = a
          let assert Ok(num2) = b
          let diff = num1 + num2
          io.debug(#(num1, num2, diff))
          // io.debug(
          //   "a: " <> int.to_string(num1) <> " b: " <> int.to_string(num2),
          // )
          // io.debug(diff)
          let update_number =
            dict.insert(num, index, int.min(9, 9 - diff))
            |> dict.insert(i, int.min(9, 9 + diff))
          #(update_number, stack)
        }
      }
    })
  dict.values(res) |> io.debug
}

// 95469986990928
// 91699394894995

pub fn part1(input: String) -> Int {
  let #(div1, dicv26) = parse(input) |> get_relevant_adds
  io.debug(div1)
  io.debug(dicv26)
  let model_number = get_model_number(div1, dicv26)
  int.undigits(model_number, 10) |> result.unwrap(0)
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
