defmodule Day9 do
  def parse_line(line) do
    line |> String.split(" ") |> Enum.map(&String.to_integer/1)
  end

  def predict_next_value(sequence) do
    d_sequence =
      Enum.zip(Enum.slice(sequence, 1..-1), Enum.slice(sequence, 0..-2))
      |> Enum.map(fn {a, b} -> a - b end)

    case Enum.uniq(d_sequence) |> length do
      0 -> 0
      1 -> List.last(sequence) + List.first(d_sequence)
      _ -> List.last(sequence) + predict_next_value(d_sequence)
    end
  end

  def predict_prev_value(sequence) do
    d_sequence =
      Enum.zip(Enum.slice(sequence, 1..-1), Enum.slice(sequence, 0..-2))
      |> Enum.map(fn {a, b} -> a - b end)

    case Enum.uniq(d_sequence) |> length do
      0 -> 0
      1 -> List.first(sequence) - List.first(d_sequence)
      _ -> List.first(sequence) - predict_prev_value(d_sequence)
    end
  end

  def solve_part1(lines) do
    lines
    |> Enum.map(&Day9.parse_line/1)
    |> Enum.map(&Day9.predict_next_value/1)
    |> Enum.sum()
  end

  def solve_part2(lines) do
    lines
    |> Enum.map(&Day9.parse_line/1)
    |> Enum.map(&Day9.predict_prev_value/1)
    |> Enum.sum()
  end
end
