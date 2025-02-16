import day06.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "3,4,3,1,2" |> part1 |> should.equal(5934)
}

pub fn part2_test() {
  "3,4,3,1,2" |> part2 |> should.equal(26_984_457_539)
}
