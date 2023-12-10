defmodule Day10 do
  def get_square({i, j}, map) do
    sq = Map.get(map, {i, j}, nil)
    if sq, do: {{i, j}, sq}, else: nil
  end

  def valid_directions("S"), do: [{-1, 0, "N"}, {1, 0, "S"}, {0, -1, "W"}, {0, 1, "E"}]
  def valid_directions("|"), do: [{-1, 0, "N"}, {1, 0, "S"}]
  def valid_directions("-"), do: [{0, -1, "W"}, {0, 1, "E"}]
  def valid_directions("L"), do: [{-1, 0, "N"}, {0, 1, "E"}]
  def valid_directions("J"), do: [{-1, 0, "N"}, {0, -1, "W"}]
  def valid_directions("7"), do: [{1, 0, "S"}, {0, -1, "W"}]
  def valid_directions("F"), do: [{1, 0, "S"}, {0, 1, "E"}]
  def valid_directions("."), do: []

  def opposite("N"), do: "S"
  def opposite("S"), do: "N"
  def opposite("W"), do: "E"
  def opposite("E"), do: "W"

  def find_start(map) do
    {loc, _} =
      map
      |> Map.to_list()
      |> Enum.filter(fn {_, elem} -> elem == "S" end)
      |> List.first()

    loc
  end

  def get_neighbors({i, j}, map) do
    {_, sq} = get_square({i, j}, map)
    directions = valid_directions(sq)

    # all allowed directions
    allowed_directions =
      directions
      |> Enum.map(fn {di, dj, dir} -> {dir, get_square({i + di, j + dj}, map)} end)
      |> Enum.filter(fn {_, t} -> t end)

    # now make sure the pipe matches on the other end
    allowed_directions
    |> Enum.filter(fn {dir, {_, next}} ->
      valid_directions(next)
      |> Enum.map(fn {_, _, d} -> d end)
      |> Enum.member?(opposite(dir))
    end)
    |> Enum.map(fn {_, {new_loc, _}} -> new_loc end)
  end

  def find_loop(map) do
    start = find_start(map)

    queue = :queue.new()
    queue = :queue.in({start, 0}, queue)
    tagged = MapSet.new([start])

    # unfold over queue and visited
    Stream.unfold({queue, tagged}, fn {q, t} ->
      case :queue.len(q) do
        0 ->
          nil

        _ ->
          {{_, {current, steps}}, q} = :queue.out(q)
          # add all neighbors to the queue
          neighbors = get_neighbors(current, map)

          # update queue and tagged
          {q, t} =
            neighbors
            |> Enum.reduce({q, t}, fn loc, {q, t} ->
              case MapSet.member?(t, loc) do
                # already tagged
                true -> {q, t}
                _ -> {:queue.in({loc, steps + 1}, q), t |> MapSet.put(loc)}
              end
            end)

          # return current location and # of steps to get there
          {{current, steps}, {q, t}}
      end
    end)
    |> Enum.into([])
  end

  def get_map(lines) do
    lines
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {elem, j} -> {{i, j}, elem} end)
    end)
    |> Enum.into(%{})
  end

  def solve_part1(input) do
    lines =
      input
      |> String.trim()
      |> String.split("\n")

    map = get_map(lines)

    map
    |> find_loop
    |> Enum.map(fn {_, s} -> s end)
    |> Enum.max()
  end
end
