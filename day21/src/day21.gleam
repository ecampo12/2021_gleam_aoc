import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import rememo/memo
import simplifile.{read}

fn parse(input: String) -> #(Int, Int) {
  case
    string.split(input, "\n")
    |> list.map(fn(x) {
      let assert Ok(num) = string.split(x, ": ") |> list.last()
      num |> int.parse |> result.unwrap(0)
    })
  {
    [p1, p2] -> #(p1, p2)
    _ -> #(-1, -1)
  }
}

fn practice_game(p1: Int, p2: Int, score1: Int, score2: Int, turn: Int) -> Int {
  case score2 > 999 {
    True -> 3 * turn * score1
    False -> {
      let p1 = {
        case { p1 + { 9 * turn } + 6 } % 10 == 0 {
          True -> 10
          False -> { p1 + { 9 * turn } + 6 } % 10
        }
      }
      // Note: to future me, players are taking turns playing.
      practice_game(p2, p1, score2, score1 + p1, turn + 1)
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(p1, p2) = parse(input)
  practice_game(p1, p2, 0, 0, 0)
}

// rememo comes in handy again.
fn real_game(p1: Int, p2: Int, score1: Int, score2: Int, cache) -> #(Int, Int) {
  use <- memo.memoize(cache, #(p1, p2, score1, score2))
  case score2 > 20 {
    True -> #(0, 1)
    False -> {
      [#(3, 1), #(4, 3), #(5, 6), #(6, 7), #(7, 6), #(8, 3), #(9, 1)]
      |> list.fold(#(0, 0), fn(acc, x) {
        let #(roll_sum, freq) = x
        let new_pos = case { p1 + roll_sum } % 10 == 0 {
          True -> 10
          False -> { p1 + roll_sum } % 10
        }
        let new_score1 = score1 + new_pos
        let #(p2w, p1w) = real_game(p2, new_pos, score2, new_score1, cache)
        #(acc.0 + p1w * freq, acc.1 + p2w * freq)
      })
    }
  }
}

pub fn part2(input: String) -> Int {
  use cache <- memo.create()
  let #(p1, p2) = parse(input)
  let wins = real_game(p1, p2, 0, 0, cache)
  int.max(wins.0, wins.1)
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
