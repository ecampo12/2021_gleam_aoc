import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/set
import simplifile.{read}

fn parse(input: String) -> #(Int, Int, Int, Int) {
  let assert Ok(re) = regexp.from_string("(-?\\d+)")
  let nums =
    regexp.scan(re, input)
    |> list.map(fn(x) { x.content |> int.parse |> result.unwrap(0) })
  case nums {
    [x1, x2, y1, y2] -> #(x1, x2, y1, y2)
    _ -> #(0, 0, 0, 0)
  }
}

pub fn part1(input: String) -> Int {
  let #(_, _, y1, _) = parse(input)
  let vy_max = int.absolute_value(y1) - 1
  { vy_max * { vy_max + 1 } } / 2
}

fn find_min_vx(x_min: Int) -> Int {
  { -1.0 +. { int.square_root(1 + 8 * x_min) |> result.unwrap(0.0) } }
  |> float.divide(2.0)
  |> result.unwrap(0.0)
  |> float.floor
  |> float.truncate
}

pub fn is_on_target(vx: Int, vy: Int, target: #(Int, Int, Int, Int)) -> Bool {
  do_check(0, 0, vx, vy, target)
}

fn do_check(
  x: Int,
  y: Int,
  vx: Int,
  vy: Int,
  target: #(Int, Int, Int, Int),
) -> Bool {
  let #(x1, x2, y1, y2) = target
  let x = x + vx
  let y = y + vy
  let vx = int.max(0, vx - 1)
  let vy = vy - 1

  case x <= x2 && y >= y1 {
    True ->
      case x1 <= x && y <= y2 {
        True -> True
        False -> do_check(x, y, vx, vy, target)
      }
    False -> False
  }
}

// We limit the search to the smallest vx and largest vx that can hit the target.
// We used a bunch of math to both values, it's left to the reader derive the formulas.
pub fn part2(input: String) -> Int {
  let target = parse(input)
  let vx_min = find_min_vx(target.0)
  let vx_max = target.1
  let vy_min = target.2
  let vy_max = int.absolute_value(target.2) - 1

  list.range(vx_min, vx_max)
  |> list.fold(set.new(), fn(acc, vx) {
    list.range(vy_min, vy_max)
    |> list.fold(acc, fn(bcc, vy) {
      case is_on_target(vx, vy, target) {
        True -> set.insert(bcc, #(vx, vy))
        False -> bcc
      }
    })
  })
  |> set.size
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
