import day01.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "199
200
208
210
200
207
240
269
260
263"
  |> part1
  |> should.equal(7)
}

pub fn part2_test() {
  "199
200
208
210
200
207
240
269
260
263"
  |> part2
  |> should.equal(5)
}
