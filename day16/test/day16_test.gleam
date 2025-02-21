import day16.{part1, part2}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  let tests = [
    // some of the values differ from what the site says, but I checked these values with other solutions.
    #("D2FE28", 6),
    #("38006F45291200", 9),
    #("EE00D40C823060", 14),
    #("8A004A801A8002F478", 16),
    #("620080001611562C8802118E34", 12),
    #("C0015000016115A2E0802F182340", 23),
    #("A0016C880162017C3686B18A2E0002F430", 33),
  ]

  list.map(tests, fn(t) {
    let #(input, expected) = t
    let actual = part1(input)
    actual |> should.equal(expected)
  })
}

pub fn part2_test() {
  let tests = [
    #("C200B40A82", 3),
    #("04005AC33890", 54),
    #("880086C3E88112", 7),
    #("CE00C43D881120", 9),
    #("D8005AC2A8F0", 1),
    #("F600BC2D8F", 0),
    #("F600BC2D8F", 0),
    #("9C0141080250320F1802104A08", 1),
  ]

  list.map(tests, fn(t) {
    let #(input, expected) = t
    let actual = part2(input)
    actual |> should.equal(expected)
  })
}
