defmodule Day19 do
  def parse_input(input) do
    [rules, parts] =
      input
      |> String.trim()
      |> String.split("\n\n")

    rules =
      rules
      |> String.split("\n")
      |> Enum.map(fn rule ->
        [name, conditions_str] = String.split(rule, "{")
        conditions_str = String.slice(conditions_str, 0..(String.length(conditions_str) - 2))

        conditions =
          conditions_str
          |> String.split(",")

        {name, conditions}
      end)
      |> Enum.into(%{})

    parts =
      parts
      |> String.split("\n")
      |> Enum.map(fn line ->
        [_ | matches] = Regex.run(~r/\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}/, line)
        [x, m, a, s] = Enum.map(matches, &String.to_integer/1)
        %{x: x, m: m, a: a, s: s}
      end)

    {rules, parts}
  end

  def eval_rule(part, rule) do
    if String.contains?(rule, ":") do
      [condition, next] = String.split(rule, ":")

      property = String.at(condition, 0) |> String.to_atom()
      comparator = String.at(condition, 1)
      value = String.slice(condition, 2..String.length(condition)) |> String.to_integer()

      result =
        case comparator do
          ">" -> Access.get(part, property) > value
          "<" -> Access.get(part, property) < value
        end

      if result, do: next, else: false
    else
      rule
    end
  end

  def valid_bounds?(current_bounds) do
    current_bounds
    |> Map.values()
    |> Enum.all?(fn {lb, ub} -> lb <= ub end)
  end

  def combinations(bounds) do
    bounds
    |> Map.values()
    |> Enum.map(fn {lb, ub} -> max(0, ub - lb + 1) end)
    |> Enum.product()
  end

  def update_bounds(current_bounds, rules, current_rules) do
    if valid_bounds?(current_bounds) do
      [rule | rest] = current_rules

      if String.contains?(rule, ":") do
        [condition, next] = String.split(rule, ":")

        property = String.at(condition, 0) |> String.to_atom()
        comparator = String.at(condition, 1)
        value = String.slice(condition, 2..String.length(condition)) |> String.to_integer()

        {lb, ub} = Map.get(current_bounds, property)

        matched_bounds =
          case comparator do
            ">" -> Map.replace(current_bounds, property, {value + 1, ub})
            "<" -> Map.replace(current_bounds, property, {lb, value - 1})
          end

        unmatched_bounds =
          case comparator do
            ">" -> Map.replace(current_bounds, property, {lb, value})
            "<" -> Map.replace(current_bounds, property, {value, ub})
          end

        case next do
          "A" ->
            [matched_bounds] ++ update_bounds(unmatched_bounds, rules, rest)

          "R" ->
            [] ++ update_bounds(unmatched_bounds, rules, rest)

          n ->
            update_bounds(matched_bounds, rules, Map.get(rules, n)) ++
              update_bounds(unmatched_bounds, rules, rest)
        end
      else
        case rule do
          "A" -> [current_bounds]
          "R" -> []
          next -> update_bounds(current_bounds, rules, Map.get(rules, next))
        end
      end
    else
      []
    end
  end

  def eval_rules(part, rules, current_rules) do
    [current_rule | rest] = current_rules

    case eval_rule(part, current_rule) do
      "A" -> true
      "R" -> false
      false -> eval_rules(part, rules, rest)
      next_rule -> eval_rules(part, rules, Map.get(rules, next_rule))
    end
  end

  def solve_1(parts, rules) do
    parts
    |> Enum.filter(fn part -> eval_rules(part, rules, Map.get(rules, "in")) end)
    |> Enum.map(fn part -> part |> Map.values() |> Enum.sum() end)
    |> Enum.sum()
  end

  def solve_2(rules) do
    valid_bounds = %{x: {1, 4000}, m: {1, 4000}, s: {1, 4000}, a: {1, 4000}}

    update_bounds(valid_bounds, rules, Map.get(rules, "in"))
    |> Enum.map(&combinations/1)
    |> Enum.sum()
  end
end
