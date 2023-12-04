defmodule Day4 do
  def parse_line(line) do
    [winning_str, numbers_str] =
      line
      |> String.split(": ")
      |> List.last()
      |> String.split(" | ")

    winning_set =
      Regex.scan(~r/\d+/, winning_str)
      |> Enum.flat_map(& &1)
      |> Enum.map(&String.to_integer/1)
      |> MapSet.new()

    numbers_set =
      Regex.scan(~r/\d+/, numbers_str)
      |> Enum.flat_map(& &1)
      |> Enum.map(&String.to_integer/1)
      |> MapSet.new()

    {winning_set, numbers_set}
  end

  def overlap(winning_set, numbers_set) do
    MapSet.intersection(winning_set, numbers_set)
    |> MapSet.size()
  end

  def solve_part1(lines) do
    lines
    |> Enum.map(fn line ->
      {winning_set, numbers_set} = parse_line(line)

      o = overlap(winning_set, numbers_set)
      if o > 0, do: 2 ** (o - 1), else: 0
    end)
    |> Enum.sum()
  end

  def update_copies(copies, _index, 0, _scratches), do: copies

  def update_copies(copies, index, overlap, scratches) do
    Enum.reduce(1..overlap, copies, fn j, c ->
      {_, result} =
        c
        |> Map.get_and_update(index + j, fn current ->
          case current do
            nil -> {current, scratches}
            current -> {current, current + scratches}
          end
        end)

      result
    end)
  end

  def solve_part2(lines) do
    {_, total} =
      lines
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce({Map.new(), 0}, fn {index, line}, {copies, count} ->
        {winning_set, numbers_set} =
          line
          |> Day4.parse_line()

        overlap = Day4.overlap(winning_set, numbers_set)

        # amount of scratches for current game
        scratches = 1 + Map.get(copies, index, 0)

        # update the map that keeps track of how many copies we have
        new_copies = update_copies(copies, index, overlap, scratches)

        {new_copies, count + scratches}
      end)

    total
  end
end
