import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/string
import simplifile.{read}

const hex_to_bin = [
  #("0", "0000"),
  #("1", "0001"),
  #("2", "0010"),
  #("3", "0011"),
  #("4", "0100"),
  #("5", "0101"),
  #("6", "0110"),
  #("7", "0111"),
  #("8", "1000"),
  #("9", "1001"),
  #("A", "1010"),
  #("B", "1011"),
  #("C", "1100"),
  #("D", "1101"),
  #("E", "1110"),
  #("F", "1111"),
]

type Packet {
  Packet(version: Int, type_id: Int, data: Int, sub_packets: List(Packet))
}

fn bin_to_int(index: Int, len: Int, bin: String) -> #(Int, Int) {
  #(
    string.slice(bin, index, len)
      |> int.base_parse(2)
      |> result.unwrap(-1),
    index + len,
  )
}

fn parse(input: String) -> Packet {
  let hex_dict = dict.from_list(hex_to_bin)
  {
    string.to_graphemes(input)
    |> list.fold("", fn(acc, x) {
      let assert Ok(bin) = dict.get(hex_dict, x)
      acc <> bin
    })
    |> parse_packet(0, _)
  }.0
}

// The problem is just parsing the binary string into the Packet struct, I had two options:
//    1. keep the index as a state and pass it around
//    2. modify the bin string to remove the parsed part
// I chose the first one because removing the parsed part from the bin string seemed more complex,
// but that was before I realized that I could use the `string.drop_start` function to remove the
// parsed part from the bin string, so I could have chosen the second option. It would've been
// easier to understand and implement. 
fn parse_packet(index: Int, bin: String) -> #(Packet, Int) {
  let #(version, index) = bin_to_int(index, 3, bin)
  let #(type_id, index) = bin_to_int(index, 3, bin)
  let #(packet, i) = case type_id {
    // _, -1 -> #(Packet(0, 0, 0, []), index + 1)
    4 -> parse_literal(index, bin)
    _ -> {
      let #(len_type, i) = bin_to_int(index, 1, bin)
      case len_type == 0 {
        True -> parse_len_op(i, bin)
        False -> parse_counter_op(i, bin)
      }
    }
  }
  #(Packet(..packet, version: version, type_id: type_id), i)
}

fn parse_literal(index: Int, bin: String) -> #(Packet, Int) {
  let bits =
    string.length(bin)
    |> list.range(0, _)
    |> list.fold_until([], fn(acc, i) {
      let str = string.slice(bin, index + i * 5, 5)
      case string.starts_with(str, "1") {
        // Used '[..acc, [..]]' instead of 'list.append(acc, [..])' before I realized that it reverses the list
        // throwing off the order of the bits. The given tests didn't catch this bug because most of the literals fit in 5 bits.
        True -> list.Continue(list.append(acc, [string.drop_start(str, 1)]))
        False -> list.Stop(list.append(acc, [string.drop_start(str, 1)]))
      }
    })
  let data =
    string.join(bits, "")
    |> int.base_parse(2)
    |> result.unwrap(0)

  #(Packet(0, 0, data, []), index + { list.length(bits) * 5 })
}

fn parse_len_op(index: Int, bin: String) -> #(Packet, Int) {
  let #(len, index) = bin_to_int(index, 15, bin)
  let #(sub_packets, _) = do_parse_len_op(bin, index + len, index)
  #(Packet(0, 0, 0, sub_packets), index + len)
}

fn do_parse_len_op(bin: String, i: Int, j: Int) -> #(List(Packet), Int) {
  case j < i, string.length(bin) <= i || string.length(bin) <= j {
    // the last condition is to avoid infinite loop
    False, _ -> #([], i)
    _, True -> #([], i)
    True, False -> {
      let #(packet, index) = parse_packet(j, bin)
      let #(packets, index) = do_parse_len_op(bin, i, index)
      #(list.append([packet], packets), index)
    }
  }
}

fn parse_counter_op(index: Int, bin: String) -> #(Packet, Int) {
  let #(count, index) = bin_to_int(index, 11, bin)
  let #(sub_packets, index) =
    list.range(0, count - 1)
    |> list.fold(#([], index), fn(acc, _i) {
      let #(packets, i) = parse_packet(acc.1, bin)
      #(list.append(acc.0, [packets]), i)
    })
  #(Packet(0, 0, 0, sub_packets), index)
}

fn verisions_sum(p: Packet) -> Int {
  case p.sub_packets {
    [] -> p.version
    _ ->
      p.version
      + list.fold(p.sub_packets, 0, fn(acc, x) { acc + verisions_sum(x) })
  }
}

pub fn part1(input: String) -> Int {
  parse(input) |> verisions_sum
}

fn compare(packet: Packet, cond: Order) -> Int {
  let a =
    list.first(packet.sub_packets)
    |> result.unwrap(Packet(0, 0, 0, []))
    |> eval
  let b =
    list.last(packet.sub_packets)
    |> result.unwrap(Packet(0, 0, 0, []))
    |> eval
  case cond {
    order.Gt ->
      case a > b {
        True -> 1
        False -> 0
      }
    order.Lt ->
      case a < b {
        True -> 1
        False -> 0
      }
    order.Eq ->
      case a == b {
        True -> 1
        False -> 0
      }
  }
}

fn eval(packet: Packet) -> Int {
  case packet.type_id {
    0 -> list.map(packet.sub_packets, eval) |> int.sum
    1 -> list.map(packet.sub_packets, eval) |> int.product
    2 ->
      list.map(packet.sub_packets, eval)
      |> list.sort(int.compare)
      |> list.first
      |> result.unwrap(0)
    3 ->
      list.map(packet.sub_packets, eval)
      |> list.sort(int.compare)
      |> list.last
      |> result.unwrap(0)
    4 -> packet.data
    5 -> compare(packet, order.Gt)
    6 -> compare(packet, order.Lt)
    7 -> compare(packet, order.Eq)
    _ -> -1
  }
}

pub fn part2(input: String) -> Int {
  parse(input) |> eval
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
