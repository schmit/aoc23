defmodule String.Extra do
  def substrings(str, size) do
    0..(String.length(str) - 1)
    |> Enum.map(&String.slice(str, &1..(&1 + size)))
  end
end

defmodule Day1 do
  def filter_to_integers(line) do
    line
    |> String.graphemes()
    |> Enum.filter(fn char ->
      case Integer.parse(char) do
        {_, ""} -> true
        _ -> false
      end
    end)
  end

  def concatenate_first_and_last(list) do
    List.first(list) <> List.last(list)
  end

  def solve_part1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&Day1.filter_to_integers/1)
    |> Enum.map(fn integers ->
      integers
      |> Day1.concatenate_first_and_last()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  def parse_text_to_number(s) do
    text_to_numbers = %{
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9"
    }

    case Integer.parse(String.first(s)) do
      {_, ""} ->
        String.first(s)

      :error ->
        text_to_numbers
        |> Enum.find(
          {"", ""},
          fn {text, _} -> String.starts_with?(s, text) end
        )
        |> elem(1)
    end
  end

  def solve_part2(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn integers ->
      integers
      |> String.Extra.substrings(5)
      |> Enum.map(&Day1.parse_text_to_number/1)
    end)
    |> Enum.map(fn integers ->
      integers
      |> Enum.filter(fn x -> x !== "" end)
      |> Day1.concatenate_first_and_last()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end
end
