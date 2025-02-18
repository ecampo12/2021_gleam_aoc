import day11.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"

pub fn part1_test() {
  part1(input) |> should.equal(1656)
}

pub fn part2_test() {
  part2(input) |> should.equal(195)
}
