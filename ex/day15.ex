defmodule Day15 do
  def hash(instruction) do
    instruction
    |> String.to_charlist()
    |> Enum.reduce(0, fn ch, h ->
      rem(17 * (h + ch), 256)
    end)
  end

  def get_label(instruction) do
    instruction
    |> String.split("=")
    |> List.first()
    |> String.split("-")
    |> List.first()
  end

  def get_value(instruction) do
    lens_str =
      instruction
      |> String.split("=")
      |> List.last()

    case Integer.parse(lens_str) do
      {value, ""} -> value
      _ -> nil
    end
  end

  def put_lenses(instructions) do
    instructions
    |> Enum.reduce(%{}, fn instruction, boxes ->
      label = get_label(instruction)
      box_id = hash(label)
      value = get_value(instruction)
      current_lenses = Map.get(boxes, box_id, [])

      if String.ends_with?(instruction, "-") do
        new_lenses =
          current_lenses
          |> Enum.filter(fn {l, _} -> l != label end)

        Map.put(boxes, box_id, new_lenses)
      else
        existing_lens =
          current_lenses
          |> Enum.with_index()
          |> Enum.filter(fn {{l, _}, _} -> l == label end)
          |> List.first()

        new_lenses =
          case existing_lens do
            nil ->
              [{label, value} | current_lenses]

            {{label, _}, index} ->
              List.replace_at(current_lenses, index, {label, value})
          end

        Map.put(boxes, box_id, new_lenses)
      end
    end)
    |> Enum.into([])
    |> Enum.map(fn {k, v} -> {k, Enum.reverse(v)} end)
  end

  def score_boxes(boxes) do
    boxes
    |> Enum.map(fn {box_id, lenses} ->
      lens_score =
        lenses
        |> Enum.with_index()
        |> Enum.map(fn {{_, focal}, index} -> focal * (index + 1) end)
        |> Enum.sum()

      (box_id + 1) * lens_score
    end)
    |> Enum.sum()
  end
end
