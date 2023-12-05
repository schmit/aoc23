defmodule RangeMap do
  # an "efficient" map to look up keys based on a range
  # for each range we store
  # RM[min_source] = {min_dest, length}

  # to find the value for a particular index
  # we find the largest key in RM that is smaller than the index
  # then we check if the index lies within the range of this key
  # if so, we use the range to compute the destination
  # otherwise return the index

  def create_range_map(map_str) do
    [_ | ranges_str] =
      map_str
      |> String.split("\n")

    ranges =
      ranges_str
      |> Enum.map(&Regex.scan(~r/\d+/, &1))
      |> Enum.map(fn row ->
        row |> Enum.map(fn e -> List.first(e) |> String.to_integer() end)
      end)

    ranges
    |> Enum.reduce(%{}, fn [dest_start, source_start, length], range_map ->
      range_map |> Map.put(source_start, {dest_start, length})
    end)
  end

  def map_index(range_map, index) do
    # find the value in range_map corresponding to the index
    start =
      range_map
      |> Map.keys()
      |> Enum.filter(&(&1 <= index))
      |> Enum.max(&>=/2, fn -> -1 end)

    case start do
      -1 ->
        # IO.puts("#{index} -> #{index}")
        index

      start ->
        {dest_start, length} = Map.get(range_map, start)

        delta = index - start
        result = if delta < length, do: dest_start + delta, else: index
        # IO.puts("#{index} -> #{result}")
        result
    end
  end

  def map_index_with_step(range_map, index) do
    # same as above but also return the minimum
    # number of steps where the range_map jumps
    # that is range_map[i+s] != range_map[i] + s

    start =
      range_map
      |> Map.keys()
      |> Enum.filter(&(&1 <= index))
      |> Enum.max(&>=/2, fn -> nil end)

    case start do
      nil ->
        # next key in map
        next_key = range_map |> Map.keys() |> Enum.min(fn -> nil end)

        case next_key do
          nil -> {index, nil}
          k -> {index, k - index}
        end

      start ->
        {dest_start, length} = Map.get(range_map, start)
        delta = index - start

        if delta < length do
          # index falls in previous key range
          out_of_range = start + length
          {dest_start + delta, out_of_range - index}
        else
          # index does not fall in previous key range
          # find the next key
          next_key =
            range_map
            |> Map.keys()
            |> Enum.filter(&(&1 > index))
            |> Enum.min(fn -> nil end)

          step =
            case next_key do
              nil -> nil
              k -> k - index
            end

          {index, step}
        end
    end
  end
end

defmodule Day5 do
  def chain_range_maps(start_index, range_maps) do
    # iterate through all the range maps to update the index
    range_maps
    |> Enum.reduce(start_index, &RangeMap.map_index/2)
  end

  def chain_range_maps_with_step(start_index, range_maps) do
    # same as above but also keep track of the minimum
    # step s such that f(i+s) == f(i) + s does not necessarily hold
    # because we are jumping to a different map interval
    range_maps
    |> Enum.reduce(
      {start_index, nil},
      fn range_map, {current_index, current_pad} ->
        {new_index, step} = RangeMap.map_index_with_step(range_map, current_index)

        new_step =
          case {current_pad, step} do
            {nil, nil} -> nil
            {nil, p} -> p
            {p, nil} -> p
            {p, q} -> min(p, q)
          end

        {new_index, new_step}
      end
    )
  end

  def process_range([start, length], range_maps) do
    # find the minimum value in an input range
    # by stepping efficiently through the range
    # note that, unless there is a discontinuity in one
    # of the maps, the we have value(index+1) = value(index) + 1
    # so we only need to check the discontinuities
    Stream.unfold(
      start,
      fn current_index ->
        cond do
          current_index > start + length ->
            nil

          true ->
            {value, step} = Day5.chain_range_maps_with_step(current_index, range_maps)
            {value, current_index + step}
        end
      end
    )
    |> Enum.min()
  end

  def solve_part1(input) do
    [seeds_str | maps_str] =
      input
      |> String.trim()
      |> String.split("\n\n")

    range_maps = maps_str |> Enum.map(&RangeMap.create_range_map/1)

    seeds_str
    |> String.split(": ")
    |> List.last()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Day5.chain_range_maps(&1, range_maps))
    |> Enum.min()
  end

  def solve_part2(input) do
    [seeds_str | maps_str] =
      input
      |> String.trim()
      |> String.split("\n\n")

    range_maps = maps_str |> Enum.map(&RangeMap.create_range_map/1)

    seeds_str
    |> String.split(": ")
    |> List.last()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&Day5.process_range(&1, range_maps))
    |> Enum.min()
  end
end
