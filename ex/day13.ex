defmodule Day13 do
  def horizontal_map(pattern) do
    pattern
    |> Enum.with_index()
    |> Enum.map(fn {pat, i} -> {i, pat} end)
    |> Enum.into(%{})
  end

  def transpose(rows) do
    rows
    |> Enum.map(&String.graphemes/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end

  def vertical_map(pattern) do
    pattern
    |> transpose
    |> horizontal_map
  end

  def reflection_finder(map, validity_check) do
    rows = map |> Map.keys() |> length

    1..(rows - 1)
    |> Enum.filter(&validity_check.(&1, map))
    |> List.first()
  end

  def find_reflection(map), do: reflection_finder(map, &is_valid/2)

  def find_reflection_with_smudge(map), do: reflection_finder(map, &is_valid_with_smudge/2)

  def is_valid(loc, map) do
    rows = map |> Map.keys() |> length

    0..(rows - 1)
    |> Enum.all?(fn i ->
      case {Map.get(map, loc - i - 1), Map.get(map, loc + i)} do
        {nil, _} -> true
        {_, nil} -> true
        {x, y} -> x == y
      end
    end)
  end

  def edit_distance(a, b) do
    Enum.zip(a |> String.graphemes(), b |> String.graphemes())
    |> Enum.map(fn {x, y} -> if x == y, do: 0, else: 1 end)
    |> Enum.sum()
  end

  def is_valid_with_smudge(loc, map) do
    # we know that if there is a smudge
    # the edit distance should be exactly 1
    # when summed across all reflection pairs
    rows = map |> Map.keys() |> length

    total_edit_distance =
      0..(rows - 1)
      |> Enum.map(fn i ->
        case {Map.get(map, loc - i - 1), Map.get(map, loc + i)} do
          {nil, _} -> 0
          {_, nil} -> 0
          {x, y} -> edit_distance(x, y)
        end
      end)
      |> Enum.sum()

    total_edit_distance == 1
  end

  def score_pattern(pattern, reflection_finder) do
    hor_map = horizontal_map(pattern)
    hor_reflection = reflection_finder.(hor_map)

    case hor_reflection do
      nil ->
        ver_map = vertical_map(pattern)
        ver_reflection = reflection_finder.(ver_map)
        ver_reflection

      _ ->
        100 * hor_reflection
    end
  end

  def solve_part1(patterns) do
    patterns
    |> Enum.map(fn pat -> score_pattern(pat, &find_reflection/1) end)
    |> Enum.sum()
  end

  def solve_part2(patterns) do
    patterns
    |> Enum.map(fn pat -> score_pattern(pat, &find_reflection_with_smudge/1) end)
    |> Enum.sum()
  end
end
