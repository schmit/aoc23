defmodule Day16 do
  def next_loc({i, j}, :up), do: {i - 1, j}
  def next_loc({i, j}, :down), do: {i + 1, j}
  def next_loc({i, j}, :left), do: {i, j - 1}
  def next_loc({i, j}, :right), do: {i, j + 1}

  def beam_next({_, _, nil}, _), do: []

  def beam_next({loc, dir, "."}, map) do
    nl = next_loc(loc, dir)
    nv = Map.get(map, nl)

    case nv do
      nil -> []
      _ -> [{nl, dir, nv}]
    end
  end

  def beam_next({loc, :up, "|"}, map), do: beam_next({loc, :up, "."}, map)
  def beam_next({loc, :down, "|"}, map), do: beam_next({loc, :down, "."}, map)

  def beam_next({loc, :left, "|"}, map),
    do: beam_next({loc, :down, "."}, map) ++ beam_next({loc, :up, "."}, map)

  def beam_next({loc, :right, "|"}, map), do: beam_next({loc, :left, "|"}, map)

  def beam_next({loc, :left, "-"}, map), do: beam_next({loc, :left, "."}, map)
  def beam_next({loc, :right, "-"}, map), do: beam_next({loc, :right, "."}, map)

  def beam_next({loc, :up, "-"}, map),
    do: beam_next({loc, :right, "."}, map) ++ beam_next({loc, :left, "."}, map)

  def beam_next({loc, :down, "-"}, map), do: beam_next({loc, :up, "-"}, map)

  def beam_next({loc, :left, "\\"}, map), do: beam_next({loc, :up, "."}, map)
  def beam_next({loc, :up, "\\"}, map), do: beam_next({loc, :left, "."}, map)
  def beam_next({loc, :right, "\\"}, map), do: beam_next({loc, :down, "."}, map)
  def beam_next({loc, :down, "\\"}, map), do: beam_next({loc, :right, "."}, map)

  def beam_next({loc, :left, "/"}, map), do: beam_next({loc, :down, "."}, map)
  def beam_next({loc, :up, "/"}, map), do: beam_next({loc, :right, "."}, map)
  def beam_next({loc, :right, "/"}, map), do: beam_next({loc, :up, "."}, map)
  def beam_next({loc, :down, "/"}, map), do: beam_next({loc, :left, "."}, map)

  def bfs(start, direction, map) do
    start_state = {start, direction, Map.get(map, start)}

    queue = :queue.new()
    queue = :queue.in(start_state, queue)
    tagged = MapSet.new()
    tagged = MapSet.put(tagged, start_state)

    Stream.unfold({queue, tagged}, fn {queue, tagged} ->
      case :queue.out(queue) do
        {:empty, _} ->
          nil

        {{:value, state}, queue} ->
          next_states = beam_next(state, map)
          # update queue and tagged
          {queue, tagged} =
            next_states
            |> Enum.reduce({queue, tagged}, fn s, {q, t} ->
              case MapSet.member?(t, s) do
                # already tagged
                true -> {q, t}
                _ -> {:queue.in(s, q), t |> MapSet.put(s)}
              end
            end)

          # return current location and # of steps to get there
          {state, {queue, tagged}}
      end
    end)
  end

  def get_map(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {val, j} ->
        {{i, j}, val}
      end)
    end)
    |> Enum.into(%{})
  end

  def count_energy(start, direction, map) do
    Day16.bfs(start, direction, map)
    |> Enum.into([])
    |> Enum.map(fn {loc, _, _} -> loc end)
    |> Enum.into(MapSet.new())
    |> MapSet.size()
  end

  def solve_1(map), do: count_energy({0, 0}, :right, map)

  def solve_2(map) do
    # brute force
    i_max = map |> Map.keys() |> Enum.map(fn {i, _} -> i end) |> Enum.max()
    j_max = map |> Map.keys() |> Enum.map(fn {_, j} -> j end) |> Enum.max()

    ((0..(i_max - 1)
      |> Enum.map(fn i -> {{i, 0}, :right} end)) ++
       (0..(i_max - 1)
        |> Enum.map(fn i -> {{i, j_max}, :left} end)) ++
       (0..(j_max - 1)
        |> Enum.map(fn j -> {{0, j}, :down} end)) ++
       (0..(j_max - 1)
        |> Enum.map(fn j -> {{i_max, j}, :up} end)))
    |> Enum.map(fn {loc, dir} -> Day16.count_energy(loc, dir, map) end)
    |> Enum.max()
  end
end
