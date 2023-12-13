defmodule Day12 do
  def parse_line(line) do
    [springs, counts_str] = line |> String.split(" ")
    counts = counts_str |> String.split(",") |> Enum.map(&String.to_integer/1)
    {springs, counts}
  end

  def unfold_springs(springs) do
    0..3
    |> Enum.reduce(springs, fn _, str -> str <> "?" <> springs end)
  end

  def unfold_counts(counts) do
    0..3
    |> Enum.reduce(counts, fn _, x -> x ++ counts end)
  end

  def solve(springs, counts), do: recur({springs, counts, 0})

  def recur({"", [], 0}), do: 1
  def recur({"", [n], n}), do: 1
  def recur({"", _, _}), do: 0

  def recur({remaining, counts, current_wells}) do
    {ch, remaining} = String.split_at(remaining, 1)

    case ch do
      "." ->
        if current_wells == 0 do
          recur({remaining, counts, 0})
        else
          {current_count, next_counts} = List.pop_at(counts, 0)

          if current_count == current_wells,
            do: recur({remaining, next_counts, 0}),
            else: 0
        end

      "#" ->
        current_count = List.first(counts, 0)

        if current_wells > current_count,
          do: 0,
          else: recur({remaining, counts, current_wells + 1})

      "?" ->
        no_well = memo_recur({"." <> remaining, counts, current_wells})
        well = memo_recur({"#" <> remaining, counts, current_wells})
        no_well + well
    end
  end

  def memo_recur(args) do
    case Process.get(args) do
      nil ->
        result = recur(args)
        Process.put(args, result)
        result

      result ->
        result
    end
  end
end
