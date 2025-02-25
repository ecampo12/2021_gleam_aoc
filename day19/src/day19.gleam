import gleam/deque.{type Deque}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import glearray
import simplifile.{read}

fn parse(input: String) -> List(List(List(Int))) {
  string.split(input, "\n\n")
  |> list.map(fn(scanner) {
    string.split(scanner, "\n")
    |> list.drop(1)
    |> list.map(fn(line) {
      string.split(line, ",")
      |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    })
  })
}

fn cross_product(a: List(Int), b: List(Int)) -> List(#(Int, Int)) {
  list.flat_map(a, fn(x) { list.map(b, fn(y) { #(x, y) }) })
}

// There can be multiple values with the same count, so we need to return the
// first one we find in the list.
fn most_common(c: List(Int)) -> #(Int, Int) {
  let counter =
    list.group(c, fn(x) { x })
    |> dict.map_values(fn(_k, v) { list.length(v) })
  let max_count =
    dict.values(counter) |> list.max(int.compare) |> result.unwrap(0)
  let max_key =
    list.filter(c, fn(x) {
      let count = dict.get(counter, x) |> result.unwrap(0)
      count == max_count
    })
    |> list.first
    |> result.unwrap(0)
  #(max_key, max_count)
}

fn search_alignment(a: List(List(Int)), b: List(List(Int))) {
  let scanner1 = list.map(a, fn(x) { x |> glearray.from_list })
  let scanner2 = list.map(b, fn(x) { x |> glearray.from_list })
  let #(points, offset, _) =
    list.fold_until([0, 1, 2], #([], [], set.new()), fn(acc, i) {
      let curr =
        list.map(scanner1, fn(pos) { glearray.get(pos, i) |> result.unwrap(0) })
      let #(axis, common, count, orient) =
        list.fold_until(
          cross_product([0, 1, 2], [1, -1]),
          #(-1, -1, -1, []),
          fn(bcc, x) {
            let #(axis, flip) = x
            case set.contains(acc.2, axis) {
              True -> list.Continue(bcc)
              False -> {
                let orient =
                  list.map(scanner2, fn(pos) {
                    let assert Ok(val) = glearray.get(pos, axis)
                    val * flip
                  })
                let shift =
                  cross_product(curr, orient) |> list.map(fn(x) { x.1 - x.0 })
                let #(common, count) = most_common(shift)
                case count >= 12 {
                  True -> list.Stop(#(axis, common, count, orient))
                  False -> list.Continue(#(axis, common, count, orient))
                }
              }
            }
          },
        )
      case count < 12 {
        True -> list.Stop(acc)
        False -> {
          let new_set = acc.2 |> set.insert(axis)
          let new_points =
            list.append(acc.0, [list.map(orient, fn(v) { v - common })])
          let new_offset = list.append(acc.1, [common])
          list.Continue(#(new_points, new_offset, new_set))
        }
      }
    })
  #([list.transpose(points)], offset)
}

fn do_search(
  stack: Deque(List(List(Int))),
  queue: Deque(List(List(Int))),
  res: Set(List(Int)),
  offset: List(List(Int)),
) -> #(Set(List(Int)), List(List(Int))) {
  case deque.is_empty(stack) {
    True -> #(res, offset)
    False -> {
      let assert Ok(#(scanner1, stack)) = deque.pop_front(stack)
      let #(stack, queue, offset) =
        list.range(0, deque.length(queue) - 1)
        |> list.fold(#(stack, queue, offset), fn(acc, _x) {
          let #(stack, queue, offsets) = acc
          let #(scanner2, queue) =
            deque.pop_front(queue) |> result.unwrap(#([], queue))
          let #(points, offset) = search_alignment(scanner1, scanner2)
          case list.flatten(points) |> list.is_empty {
            False -> {
              let new_stack =
                list.filter(points, fn(x) { !list.is_empty(x) })
                |> list.fold(stack, fn(acc, x) { deque.push_back(acc, x) })

              let offsets = list.append(offsets, [offset])
              #(new_stack, queue, offsets)
            }
            True -> {
              let new_queue = deque.push_back(queue, scanner2)
              #(stack, new_queue, offsets)
            }
          }
        })
      let res = set.from_list(scanner1) |> set.union(res)
      do_search(stack, queue, res, offset)
    }
  }
}

pub fn part1(input: String) -> Int {
  let parsed = parse(input)
  let stack = [list.first(parsed) |> result.unwrap([])] |> deque.from_list
  let queue = list.rest(parsed) |> result.unwrap([]) |> deque.from_list
  let #(b, _) = do_search(stack, queue, set.new(), [])
  set.size(b)
}

fn manhattan_distance(a: List(Int), b: List(Int)) -> Int {
  list.zip(a, b)
  |> list.map(fn(x) { int.absolute_value(x.0 - x.1) })
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let parsed = parse(input)
  let stack = [list.first(parsed) |> result.unwrap([])] |> deque.from_list
  let queue = list.rest(parsed) |> result.unwrap([]) |> deque.from_list
  let #(_, sp) = do_search(stack, queue, set.new(), [])

  list.combination_pairs(sp)
  |> list.map(fn(x) { manhattan_distance(x.0, x.1) })
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
