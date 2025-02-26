import gleam/int
import gleam/io
import gleam/list
import gleam/result.{unwrap}
import gleam/string.{to_graphemes}
import glearray.{type Array}
import simplifile.{read}

// Usually I would use a dict to keep track of the coordinates and values, but decided to use a 2D array instead.
// We are pretty much re-writting the image, so it makes sense to use a 2D array for debugging purposes.
fn parse(input: String) -> #(Array(Int), Array(Array(Int))) {
  let pixel = fn(x) {
    case x == "#" {
      True -> 1
      False -> 0
    }
  }
  case string.split(input, "\n\n") {
    [algo, pic] -> {
      let algo = to_graphemes(algo) |> list.map(pixel) |> glearray.from_list
      let pic =
        string.split(pic, "\n")
        |> list.index_map(fn(row, _r) {
          to_graphemes(row)
          |> list.map(pixel)
          |> glearray.from_list
        })
        |> glearray.from_list
      #(algo, pic)
    }
    _ -> #(glearray.new(), glearray.new())
  }
}

const neighbors = [
  #(-1, -1),
  #(-1, 0),
  #(-1, 1),
  #(0, -1),
  #(0, 0),
  #(0, 1),
  #(1, -1),
  #(1, 0),
  #(1, 1),
]

fn get_neighbors(p: #(Int, Int)) -> List(#(Int, Int)) {
  list.map(neighbors, fn(d) { #(p.0 + d.0, p.1 + d.1) })
}

fn get_surroundings(
  i: Int,
  j: Int,
  pic: Array(Array(Int)),
  default: Int,
) -> List(Int) {
  let height = glearray.length(pic)
  let width = glearray.get(pic, 0) |> unwrap(glearray.new()) |> glearray.length

  get_neighbors(#(i, j))
  |> list.map(fn(p) {
    case 0 <= p.0 && p.0 < height && 0 <= p.1 && p.1 < width {
      True ->
        glearray.get(pic, p.0)
        |> unwrap(glearray.new())
        |> glearray.get(p.1)
        |> unwrap(default)
      False -> default
    }
  })
}

fn get_output_pixel(b: List(Int), algo: Array(Int)) -> Int {
  let index = list.fold(b, 0, fn(acc, x) { int.bitwise_shift_left(acc, 1) + x })
  glearray.get(algo, index) |> unwrap(0)
}

fn calculate_image(
  pic: Array(Array(Int)),
  algo: Array(Int),
  default: Int,
) -> Array(Array(Int)) {
  let height = glearray.length(pic)
  let width =
    glearray.get(pic, 0)
    |> unwrap(glearray.new())
    |> glearray.length

  list.range(-1, height)
  |> list.fold([], fn(acc, i) {
    let row =
      list.range(-1, width)
      |> list.fold([], fn(bcc, j) {
        let b = get_surroundings(i, j, pic, default)
        list.append(bcc, [get_output_pixel(b, algo)])
      })
      |> glearray.from_list
    list.append(acc, [row])
  })
  |> glearray.from_list
}

fn solve(algo: Array(Int), picture: Array(Array(Int)), loop: Int) -> Int {
  list.range(0, loop)
  |> list.fold(picture, fn(pic, i) { calculate_image(pic, algo, i % 2) })
  |> glearray.to_list
  |> list.map(glearray.to_list)
  |> list.flatten
  |> int.sum
}

pub fn part1(input: String, loop: Int) -> Int {
  let #(algo, picture) = parse(input)
  solve(algo, picture, loop - 1)
}

pub fn part2(input: String, loop: Int) -> Int {
  let #(algo, picture) = parse(input)
  solve(algo, picture, loop - 1)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input, 2)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input, 50)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
