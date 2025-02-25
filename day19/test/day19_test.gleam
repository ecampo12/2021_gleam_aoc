import day19.{part1, part2}
import gleeunit
import gleeunit/should
import simplifile.{read}

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  let assert Ok(input) = read("test/test_input.txt")
  part1(input) |> should.equal(79)
}

pub fn part2_test() {
  let assert Ok(input) = read("test/test_input.txt")
  part2(input) |> should.equal(3621)
}
