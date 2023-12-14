defmodule Day14 do
  def transpose(rows) do
    rows
    |> Enum.map(&String.graphemes/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end

  def rotate(puzzle, :north), do: transpose(puzzle)
  def rotate(puzzle, :south), do: transpose(puzzle)
  def rotate(puzzle, _), do: puzzle

  def rotate_and_tilt(puzzle, direction) do
    sort_direction =
      case direction do
        :north -> :desc
        :west -> :desc
        _ -> :asc
      end

    puzzle
    |> rotate(direction)
    |> Enum.map(fn line ->
      line
      |> String.split("#")
      |> Enum.map(fn section ->
        section
        |> String.graphemes()
        |> Enum.sort(sort_direction)
        |> Enum.join("")
      end)
      |> Enum.join("#")
    end)
    |> rotate(direction)
  end

  def cycle(puzzle) do
    puzzle
    |> rotate_and_tilt(:north)
    |> rotate_and_tilt(:west)
    |> rotate_and_tilt(:south)
    |> rotate_and_tilt(:east)
  end

  def memo_cycle(puzzle) do
    case Process.get(puzzle) do
      nil ->
        result = cycle(puzzle)
        Process.put(puzzle, result)
        result

      result ->
        result
    end
  end

  def beam_load(puzzle) do
    transposed_puzzle = transpose(puzzle)
    len = Enum.at(transposed_puzzle, 0) |> String.length()

    transposed_puzzle
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {elem, index} ->
        case elem do
          "O" -> len - index
          _ -> 0
        end
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def solve_puzzle(puzzle) do
    tilted_puzzle = rotate_and_tilt(puzzle, :north)
    beam_load(tilted_puzzle)
  end

  def cycler(puzzle, 0), do: puzzle

  def cycler(puzzle, remaining) do
    cycler(cycle(puzzle), remaining - 1)
  end

  # assume that there is a loop we eventually enter.
  # Once we know we are in the loop,
  # we can forward to being "on the last loop",
  # skipping all intermediate loops
  def cycler_with_cache(puzzle, remaining, done \\ 0, cache \\ %{})
  def cycler_with_cache(puzzle, 0, _, _), do: puzzle

  def cycler_with_cache(puzzle, remaining, done, cache) do
    case Map.get(cache, puzzle) do
      nil ->
        new_cache = cache |> Map.put(puzzle, done)
        cycler_with_cache(cycle(puzzle), remaining - 1, done + 1, new_cache)

      prev_done ->
        cycle_length = done - prev_done
        IO.puts("Found cycle of length #{cycle_length} on step #{done}")
        IO.puts("Steps remaining: #{remaining}")
        IO.puts("Skipping to run the last #{rem(remaining, cycle_length)} cycles")
        cycler(puzzle, rem(remaining, cycle_length))
    end
  end

  def solve_cycler(puzzle) do
    cycler_with_cache(puzzle, 1_000_000_000)
    |> beam_load()
  end
end
