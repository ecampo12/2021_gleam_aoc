import day18.{part1, part2}
import gleam/list
import gleam/result
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const large_input = "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"

pub fn explode_test() {
  let tests = [
    #("[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"),
    #("[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"),
    #("[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"),
    #(
      "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]",
      "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]",
    ),
    #("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"),
  ]
  list.map(tests, fn(t) {
    let #(input, expected) = t
    let p =
      input
      |> day18.parse
    let e =
      expected
      |> day18.parse
      |> list.first
      |> result.unwrap([])
    case list.first(p) {
      Ok(x) -> {
        let #(_, ans) = day18.explode(x)
        should.equal(ans, e)
      }
      Error(_) -> Nil
    }
  })
}

pub fn magnitude_test() {
  let tests = [
    #("[[1,2],[[3,4],5]]", 143),
    #("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", 1384),
    #("[[[[1,1],[2,2]],[3,3]],[4,4]]", 445),
    #("[[[[3,0],[5,3]],[4,4]],[5,5]]", 791),
    #("[[[[5,0],[7,4]],[5,5]],[6,6]]", 1137),
    #("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]", 3488),
  ]
  list.map(tests, fn(t) {
    let #(input, expected) = t
    let p =
      input
      |> day18.parse
    case list.first(p) {
      Ok(x) -> day18.magnitude(x) |> should.equal(expected)
      Error(_) -> Nil
    }
  })
}

pub fn part1_test() {
  part1(large_input)
  |> should.equal(4140)
}

pub fn part2_test() {
  part2(large_input)
  |> should.equal(3993)
}
