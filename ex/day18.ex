defmodule Day18 do
  def total_points(polygon) do
    # shoelace formula
    n = length(polygon)

    {area, boundary} =
      Enum.zip(Enum.slice(polygon, 0..(n - 2)), Enum.slice(polygon, 1..(n - 1)))
      |> Enum.reduce({0, 0}, fn {{xi, yi}, {xj, yj}}, {area, outer} ->
        {area + xi * yj / 2 - xj * yi / 2, outer + abs(xi - xj) + abs(yi - yj)}
      end)

    area = abs(area)

    # Pick's formula for number of points
    interior = area - boundary / 2 + 1
    boundary + interior
  end

  def make_polygon(instructions) do
    polygon =
      instructions
      |> Stream.scan({0, 0}, fn {dir, steps}, {x, y} ->
        case dir do
          "U" ->
            {x, y + steps}

          "D" ->
            {x, y - steps}

          "L" ->
            {x - steps, y}

          "R" ->
            {x + steps, y}
        end
      end)
      |> Enum.to_list()

    [{0, 0} | polygon]
  end

  def parse_input(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&List.to_tuple/1)
  end

  def instructions_part1({dir, val_str, _}) do
    {dir, String.to_integer(val_str)}
  end

  def instructions_part2({_, _, h}) do
    {steps, _} = String.slice(h, 2..6) |> Integer.parse(16)

    dir =
      case String.at(h, 7) do
        "0" -> "R"
        "1" -> "D"
        "2" -> "L"
        "3" -> "U"
      end

    {dir, steps}
  end

  def solve_1(content) do
    content
    |> parse_input()
    |> Enum.map(&instructions_part1/1)
    |> make_polygon()
    |> total_points()
    |> Kernel.round()
  end

  def solve_2(content) do
    content
    |> parse_input()
    |> Enum.map(&instructions_part2/1)
    |> make_polygon()
    |> total_points()
    |> Kernel.round()
  end
end
