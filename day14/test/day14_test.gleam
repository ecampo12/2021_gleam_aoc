import day14.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"

pub fn part1_test() {
  part1(input) |> should.equal(1588)
}

pub fn part2_test() {
  part2(input) |> should.equal(2_188_189_693_529)
}
