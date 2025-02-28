import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

type Range =
  #(Int, Int)

type Cuboid {
  Cuboid(x: Range, y: Range, z: Range)
}

fn parse(input: String) -> List(#(Cuboid, Int)) {
  let assert Ok(re) = regexp.from_string("-?\\d+")
  string.split(input, "\n")
  |> list.map(fn(line) {
    let state = case string.starts_with(line, "on") {
      True -> 1
      False -> -1
    }
    case
      regexp.scan(re, line)
      |> list.map(fn(x) { int.parse(x.content) })
    {
      [Ok(x1), Ok(x2), Ok(y1), Ok(y2), Ok(z1), Ok(z2)] -> {
        #(Cuboid(#(x1, x2), #(y1, y2), #(z1, z2)), state)
      }
      _ -> #(Cuboid(#(0, 0), #(0, 0), #(0, 0)), 0)
    }
  })
}

fn size(c: Cuboid) -> Int {
  { c.x.1 - c.x.0 + 1 } * { c.y.1 - c.y.0 + 1 } * { c.z.1 - c.z.0 + 1 }
}

fn intersect(c1: Cuboid, c2: Cuboid) -> Result(Cuboid, Nil) {
  let cuboid =
    Cuboid(
      #(int.max(c1.x.0, c2.x.0), int.min(c1.x.1, c2.x.1)),
      #(int.max(c1.y.0, c2.y.0), int.min(c1.y.1, c2.y.1)),
      #(int.max(c1.z.0, c2.z.0), int.min(c1.z.1, c2.z.1)),
    )
  case
    cuboid.x.0 > cuboid.x.1
    || cuboid.y.0 > cuboid.y.1
    || cuboid.z.0 > cuboid.z.1
  {
    True -> Error(Nil)
    False -> Ok(cuboid)
  }
}

fn max(c: Cuboid) -> Int {
  list.max([c.x.0, c.x.1, c.y.0, c.y.1, c.z.0, c.z.1], int.compare)
  |> result.unwrap(0)
}

fn min(c: Cuboid) -> Int {
  list.fold([c.x.0, c.x.1, c.y.0, c.y.1, c.z.0, c.z.1], c.x.0, fn(acc, x) {
    int.min(acc, x)
  })
}

// Pretty much the solution for part1 and part2 are the same except for the condition.
// We stuck with expressing cuboids in ranges instead of expanding them into individual 
// points. This is a classic Advent of Code problem, never expand the ranges.
fn reboot_process(cuboids: List(#(Cuboid, Int)), part1: Bool) -> Int {
  list.fold(cuboids, dict.new(), fn(acc, c) {
    let #(volume1, v) = c
    case part1 && { max(volume1) > 50 || min(volume1) < -50 } {
      True -> acc
      False -> {
        let update =
          dict.fold(acc, dict.new(), fn(bcc, volume2, count) {
            case intersect(volume1, volume2) {
              Error(_) -> bcc
              Ok(newcube) -> {
                dict.upsert(bcc, newcube, fn(x) {
                  case x {
                    Some(c) -> c - count
                    None -> -count
                  }
                })
                |> dict.filter(fn(_, v) { v != 0 })
              }
            }
          })
        case v == 1 {
          False -> acc
          True -> {
            let val =
              dict.get(acc, volume1)
              |> result.unwrap(0)
            dict.insert(acc, volume1, val + v)
          }
        }
        |> dict.combine(update, fn(a, b) { a + b })
      }
    }
  })
  |> dict.fold(0, fn(acc, k, v) { acc + size(k) * v })
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> reboot_process(True)
}

pub fn part2(input: String) -> Int {
  parse(input)
  |> reboot_process(False)
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
