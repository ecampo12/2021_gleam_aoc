import day03.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"
  |> part1
  |> should.equal(198)
}

pub fn part2_test() {
  "00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"
  |> part2
  |> should.equal(230)
}
