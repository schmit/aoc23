defmodule Day11 do
  def manhattan({y0, x0}, {y1, x1}) do
    abs(y1 - y0) + abs(x1 - x0)
  end

  # from: https://www.adiiyengar.com/blog/20190608/elixir-combinations
  def combinations(_list, 0), do: [[]]
  def combinations(list = [], _num), do: list

  def combinations([head | tail], num) do
    Enum.map(combinations(tail, num - 1), &[head | &1]) ++
      combinations(tail, num)
  end

  def get_row({i, _}), do: i
  def get_col({_, j}), do: j

  def get_empty_rows(galaxy_indices, _grid_size = {m, _}) do
    full_rows =
      galaxy_indices
      |> Enum.map(&get_row/1)
      |> Enum.uniq()

    MapSet.difference(
      MapSet.new(0..(m - 1)),
      MapSet.new(full_rows)
    )
  end

  def get_empty_cols(galaxy_indices, _grid_size = {_, n}) do
    full_cols =
      galaxy_indices
      |> Enum.map(&get_col/1)
      |> Enum.uniq()

    MapSet.difference(
      MapSet.new(0..(n - 1)),
      MapSet.new(full_cols)
    )
  end

  def get_universe(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def get_galaxy_indices(universe) do
    universe
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      row
      |> Enum.with_index()
      |> Enum.filter(fn {elem, _} -> elem != "." end)
      |> Enum.map(fn {_, j} ->
        {i, j}
      end)
    end)
  end

  def get_galaxies(galaxy_indices, empty_size, empty_rows, empty_cols) do
    galaxy_indices
    |> Enum.map(fn {i, j} ->
      y = empty_rows |> Enum.filter(&(&1 < i)) |> length()
      x = empty_cols |> Enum.filter(&(&1 < j)) |> length()
      {i + (empty_size - 1) * y, j + (empty_size - 1) * x}
    end)
  end

  def solve(input, empty_size) do
    universe =
      input
      |> get_universe()

    galaxy_indices =
      universe
      |> get_galaxy_indices()

    grid_size = {length(universe), length(universe |> List.first())}
    empty_rows = get_empty_rows(galaxy_indices, grid_size)
    empty_cols = get_empty_cols(galaxy_indices, grid_size)

    galaxies = get_galaxies(galaxy_indices, empty_size, empty_rows, empty_cols)

    galaxies
    |> combinations(2)
    |> Enum.map(fn [g1, g2] -> Day11.manhattan(g1, g2) end)
    |> Enum.sum()
  end
end
