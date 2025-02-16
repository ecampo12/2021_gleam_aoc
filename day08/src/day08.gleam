import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

// We can looking for the number of times 1, 4, 7, 8 apears on a segmented clock
// Thankfully we can easily identify them by their segment length
// 1 -> 2 segments
// 4 -> 4 segments
// 7 -> 3 segments
// 8 -> 7 segments
pub fn part1(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(0, fn(acc, line) {
    let parts = case string.split(line, " | ") {
      [a, b] -> #(a, b)
      _ -> #("", "")
    }
    parts.1
    |> string.split(" ")
    |> list.map(string.length)
    |> list.fold(acc, fn(bcc, len) {
      case len {
        2 | 3 | 4 | 7 -> bcc + 1
        _ -> bcc
      }
    })
  })
}

// Identifying the other numbers is a bit tricky since 2, 3, 5 have a segment length of 5, and 6, 9, 0 have a segment length of 6
// We can use the fact that the rest of the numbers share segments with 1, 4, 7, 8 to identify them.
// For example: 0 contains segments of 1, so it has 2 segments in common with 7 and shares 3 segments with 4.
pub fn part2(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(0, fn(acc, line) {
    let parts = case string.split(line, " | ") {
      [a, b] -> #(a, b)
      _ -> #("", "")
    }
    let lens =
      string.split(parts.0, " ")
      |> list.map(fn(x) {
        #(string.length(x), string.to_graphemes(x) |> set.from_list)
      })
      |> dict.from_list
    let num =
      string.split(parts.1, " ")
      |> list.map(fn(x) { string.to_graphemes(x) |> set.from_list })
      |> list.fold("", fn(bcc, s) {
        let len4 = dict.get(lens, 4) |> result.unwrap(set.new())
        let len2 = dict.get(lens, 2) |> result.unwrap(set.new())
        case
          set.size(s),
          set.intersection(s, len4) |> set.size,
          set.intersection(s, len2) |> set.size
        {
          2, _, _ -> bcc <> "1"
          3, _, _ -> bcc <> "7"
          4, _, _ -> bcc <> "4"
          7, _, _ -> bcc <> "8"
          5, 2, _ -> bcc <> "2"
          5, 3, 1 -> bcc <> "5"
          5, 3, 2 -> bcc <> "3"
          6, 4, _ -> bcc <> "9"
          6, 3, 1 -> bcc <> "6"
          6, 3, 2 -> bcc <> "0"
          _, _, _ -> bcc
        }
      })
    { int.parse(num) |> result.unwrap(0) } + acc
  })
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
