defmodule Day3 do
  def solve_part1(lines) do
    {_, _, _, valid_parts} =
      (lines ++ ["", ""])
      |> Enum.reduce({"", "", "", []}, fn line, {prev, current, next, parts} ->
        match_indices = Regex.scan(~r/\d+/, current, return: :index)

        new_parts =
          match_indices
          |> Enum.filter(fn [{s, n}] ->
            cond do
              # char before number is not a .
              s > 0 and String.at(current, s - 1) != "." ->
                true

              # char after number is not a .
              s + n < String.length(current) and String.at(current, s + n) != "." ->
                true

              # there is a char above that is not a .
              Regex.match?(
                ~r/[^\d\.]/,
                String.slice(prev, max(0, s - 1)..min(String.length(prev), s + n))
              ) ->
                true

              # there is a char below that is not a .
              Regex.match?(
                ~r/[^\d\.]/,
                String.slice(next, max(0, s - 1)..min(String.length(next), s + n))
              ) ->
                true

              true ->
                false
            end
          end)
          |> Enum.map(fn [{s, n}] ->
            current
            |> String.slice(s..(s + n - 1))
            |> String.to_integer()
          end)

        {current, next, line, new_parts ++ parts}
      end)

    Enum.sum(valid_parts)
  end

  def solve_part2(lines) do
    {_, _, _, _, gear_map} =
      (lines ++ ["", ""])
      |> Enum.reduce({"", "", "", 0, %{}}, fn line, {prev, current, next, line_id, gear_map} ->
        # find all numbers and their indices in the current line
        match_indices = Regex.scan(~r/\d+/, current, return: :index)

        match_numbers =
          match_indices
          |> Enum.map(fn [{s, n}] ->
            current
            |> String.slice(s..(s + n - 1))
            |> String.to_integer()
          end)

        # find all the gear icons in the 3 relevant lines
        prev_gear_icons =
          Regex.scan(~r/\*/, prev, return: :index)
          |> Enum.map(fn [{i, _}] -> {line_id - 1, i} end)

        current_gear_icons =
          Regex.scan(~r/\*/, current, return: :index)
          |> Enum.map(fn [{i, _}] -> {line_id, i} end)

        next_gear_icons =
          Regex.scan(~r/\*/, next, return: :index)
          |> Enum.map(fn [{i, _}] -> {line_id + 1, i} end)

        all_gear_icons = prev_gear_icons ++ current_gear_icons ++ next_gear_icons

        # create the cross product of all numbers and all gears in the 3 relevant lines
        gear_number_cross_product =
          Enum.zip(match_indices, match_numbers)
          |> Enum.flat_map(fn {[{s, n}], gear_val} ->
            all_gear_icons
            |> Enum.map(fn gear_icon -> {{s, s + n - 1}, gear_val, gear_icon} end)
          end)

        # now filter out all the gear icons that do not touch the number
        new_gear_map =
          gear_number_cross_product
          |> Enum.filter(fn {{s, t}, _, {g_row, g_col}} ->
            cond do
              # gear icon before or after number
              g_row == line_id and g_col == s - 1 -> true
              g_row == line_id and g_col == t + 1 -> true
              # gear icon on previous line
              g_row == line_id - 1 and g_col >= s - 1 and g_col <= t + 1 -> true
              # gear icon on next lines
              g_row == line_id + 1 and g_col >= s - 1 and g_col <= t + 1 -> true
              true -> false
            end
          end)
          |> Enum.map(fn {_, gear_val, gear_loc} ->
            {gear_loc, gear_val}
          end)

        # update the map of gears to numbers
        merged_gear_map =
          new_gear_map
          |> Enum.reduce(gear_map, fn {gear_loc, gear_val}, acc ->
            {_, new_acc} =
              acc
              |> Map.get_and_update(gear_loc, fn current_vals ->
                case current_vals do
                  nil -> {nil, [gear_val]}
                  gear_vals -> {nil, [gear_val | gear_vals]}
                end
              end)

            new_acc
          end)

        {current, next, line, line_id + 1, merged_gear_map}
      end)

    # take the map of gears to numbers, filter and multiply
    gear_map
    |> Map.to_list()
    |> Enum.map(fn {_, gear_vals} -> gear_vals end)
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.map(fn [x, y] -> x * y end)
    |> Enum.sum()
  end
end
