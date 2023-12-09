defmodule Day8 do
  def traverse(instructions, network, start) do
    instructions
    |> String.graphemes()
    |> Stream.cycle()
    |> Enum.reduce_while(
      {start, 0},
      fn instruction, {node, n} ->
        next_node = next(node, instruction, network)
        if node == "ZZZ", do: {:halt, n}, else: {:cont, {next_node, n + 1}}
      end
    )
  end

  def solve_part1(input) do
    [instructions, network_str] =
      input
      |> String.split("\n\n")

    network_str
    |> String.split("\n")

    network =
      network_str
      |> String.split("\n")
      |> Enum.map(&Day7.parse_graph_line/1)
      |> Enum.reduce(%{}, fn {k, v}, m ->
        Map.put(m, k, v)
      end)

    traverse(instructions, network, "AAA")
  end
end
