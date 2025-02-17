import day09.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "2199943210
3987894921
9856789892
8767896789
9899965678"

pub fn part1_test() {
  part1(input) |> should.equal(15)
}

pub fn part2_test() {
  part2(input) |> should.equal(1134)
}
