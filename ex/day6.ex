defmodule Day6 do
  def hit_record(t, r) do
    {t / 2 - :math.sqrt(t * t / 4 - r), t / 2 + :math.sqrt(t * t / 4 - r)}
  end

  def ways_to_beat_record(t, r) do
    {min_wait, max_wait} = hit_record(t, r)
    Float.ceil(max_wait - 1) - Float.floor(min_wait + 1) + 1
  end

  def parse_integers(line) do
    Regex.scan(~r"\d+", line)
    |> Enum.map(&(&1 |> List.first() |> String.to_integer()))
  end

  def solve_part1(input) do
    [time_str, records_str] =
      input
      |> Kino.Input.read()
      |> String.trim()
      |> String.split("\n")

    times = Day6.parse_integers(time_str)
    records = Day6.parse_integers(records_str)

    Enum.zip(times, records)
    |> Enum.map(fn {t, r} -> Day6.ways_to_beat_record(t, r) end)
    |> Enum.reduce(&*/2)
    |> round()
  end

  def solve_part2(input) do
    [time_str, records_str] =
      input
      |> Kino.Input.read()
      |> String.trim()
      |> String.split("\n")
      # just glue all the numbers together wee
      |> Enum.map(fn line -> line |> String.replace(" ", "") end)

    times = Day6.parse_integers(time_str)
    records = Day6.parse_integers(records_str)

    Enum.zip(times, records)
    |> Enum.map(fn {t, r} -> Day6.ways_to_beat_record(t, r) end)
    |> Enum.reduce(&*/2)
    |> round()
  end
end
