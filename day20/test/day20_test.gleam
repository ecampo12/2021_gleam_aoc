import day20.{part1}
import gleeunit
import gleeunit/should
import simplifile.{read}

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  let assert Ok(input) = read("test/test_input.txt")
  part1(input, 2) |> should.equal(31)
}
