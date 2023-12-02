defmodule Game do
  defstruct id: nil, draws: []

  defp parse_single_draw(draw_str) do
    cube_map =
      draw_str
      |> String.split(", ")
      |> Enum.map(
        &(String.split(&1, " ")
          |> Enum.reverse()
          |> then(fn [color, count] ->
            [String.to_existing_atom(color), String.to_integer(count)]
          end))
      )
      |> Map.new(fn [k, v] -> {k, v} end)

    struct(Cubes, cube_map)
  end

  defp parse_draws(observations_str) do
    draws_str = observations_str
    |> String.split("; ")
    |> Enum.map(&parse_single_draw/1)
  end

  def parse_game_string(str) do
    [game_str, obs_str] = String.split(str, ": ")
    "Game " <> id_str = game_str
    %Game{id: String.to_integer(id_str), draws: parse_draws(obs_str)}
  end
end

defmodule Cubes do
  defstruct red: 0, blue: 0, green: 0

  def draw_valid?(
        %Cubes{red: red, blue: blue, green: green} = _draw,
        %Cubes{red: max_red, blue: max_blue, green: max_green} = _max_cubes
      ) do
    cond do
      red > max_red -> false
      blue > max_blue -> false
      green > max_green -> false
      true -> true
    end
  end

  def power(%Cubes{red: red, blue: blue, green: green}) do
    red * blue * green
  end
end

defmodule Day2 do
  def game_valid?(game) do
    max_cubes = %Cubes{red: 12, green: 13, blue: 14}
    Enum.all?(Enum.map(game.draws, &Cubes.draw_valid?(&1, max_cubes)))
  end

  defp parse_contents_into_games(contents) do
    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&Game.parse_game_string/1)
  end

  def solve_part1(contents) do
    contents
    |> parse_contents_into_games
    |> Enum.filter(&game_valid?/1)
    |> Enum.map(fn game -> game.id end)
    |> Enum.sum
  end

  def find_min_cubes(game) do
    game.draws
    |> Enum.reduce(fn
        %Cubes{red: red, blue: blue, green: green},
        %Cubes{red: min_red, blue: min_blue, green: min_green} ->
      %Cubes{red: max(red, min_red), blue: max(blue, min_blue), green: max(green, min_green)}
    end)
  end

  def solve_part2(contents) do
    contents
    |> parse_contents_into_games
    |> Enum.map(&find_min_cubes/1)
    |> Enum.map(&Cubes.power/1)
    |> Enum.sum()
  end


end
