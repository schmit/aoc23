defmodule Day12 do
  def parse_line(line) do
    [springs, counts_str] = line |> String.split(" ")
    counts = counts_str |> String.split(",") |> Enum.map(&String.to_integer/1)
    {springs, counts}
  end

  def solve(springs, counts), do: recur(springs, counts, 0)

  def recur("", [], 0), do: 1
  def recur("", [n], n), do: 1
  def recur("", _, _), do: 0

  def recur(remaining, counts, current_wells) do
    # IO.puts("INPUT: #{remaining} with current wells: #{current_wells}")
    # IO.inspect(counts)

    {ch, remaining} = String.split_at(remaining, 1)

    case ch do
      "." ->
        if current_wells == 0 do
          recur(remaining, counts, 0)
        else
          {current_count, next_counts} = List.pop_at(counts, 0)

          if current_count == current_wells,
            do: recur(remaining, next_counts, 0),
            else: 0
        end

      "#" ->
        current_count = List.first(counts, 0)

        if current_wells > current_count,
          do: 0,
          else: recur(remaining, counts, current_wells + 1)

      "?" ->
        no_well = recur("." <> remaining, counts, current_wells)
        well = recur("#" <> remaining, counts, current_wells)
        no_well + well
    end
  end
end
