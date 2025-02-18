import day12.{part1, part2}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const tests = [
  #(
    "start-A
start-b
A-c
A-b
b-d
A-end
b-end",
    10,
  ),
  #(
    "dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc",
    19,
  ),
  #(
    "fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW",
    226,
  ),
]

pub fn part1_test() {
  list.map(tests, fn(x) { part1(x.0) |> should.equal(x.1) })
}

pub fn part2_test() {
  todo
}
