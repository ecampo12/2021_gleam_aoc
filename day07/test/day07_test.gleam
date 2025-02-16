import day07.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "16,1,2,0,4,2,7,1,2,14" |> part1 |> should.equal(37)
}

pub fn part2_test() {
  "16,1,2,0,4,2,7,1,2,14" |> part2 |> should.equal(168)
}
