import day15.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581"

pub fn part1_test() {
  part1(input) |> should.equal(40)
}

pub fn part2_test() {
  part2(input) |> should.equal(315)
}
