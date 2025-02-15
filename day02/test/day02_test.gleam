import day02.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "forward 5
down 5
forward 8
up 3
down 8
forward 2"
  |> part1
  |> should.equal(150)
}

pub fn part2_test() {
  "forward 5
down 5
forward 8
up 3
down 8
forward 2"
  |> part2
  |> should.equal(900)
}
