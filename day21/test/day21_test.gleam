import day21.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "Player 1 starting position: 4
Player 2 starting position: 8"

pub fn part1_test() {
  part1(input)
  |> should.equal(739_785)
}

pub fn part2_test() {
  part2(input)
  |> should.equal(444_356_092_776_315)
}
