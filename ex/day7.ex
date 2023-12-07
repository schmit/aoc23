# part 1
defmodule CamelCards do
  defstruct [:cards, :bid]

  def card_value("A"), do: 14
  def card_value("K"), do: 13
  def card_value("Q"), do: 12
  def card_value("J"), do: 11
  def card_value("T"), do: 10

  def card_value(n) do
    {value, ""} = Integer.parse(n)
    value
  end

  # five of a kind
  defp hand_value([5 | _]), do: 6
  # four of a kind
  defp hand_value([4 | _]), do: 5
  # full house, etc.
  defp hand_value([3, 2 | _]), do: 4
  defp hand_value([3 | _]), do: 3
  defp hand_value([2, 2 | _]), do: 2
  defp hand_value([2 | _]), do: 1
  defp hand_value(_), do: 0

  def compare(a, b) do
    a_score = score_hand(a)
    b_score = score_hand(b)

    cond do
      a_score > b_score ->
        :gt

      a_score < b_score ->
        :lt

      true ->
        compare_cards(a.cards, b.cards)
    end
  end

  def compare_cards([c], [d]) do
    if card_value(c) >= card_value(d), do: :gt, else: :lt
  end

  def compare_cards([c | c_rest], [d | d_rest]) do
    cond do
      card_value(c) > card_value(d) ->
        :gt

      card_value(c) < card_value(d) ->
        :lt

      true ->
        compare_cards(c_rest, d_rest)
    end
  end

  def score_hand(hand) do
    # compute a frequency list and sort it
    hand.cards
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> hand_value()
  end

  def parse(line) do
    [hand_str, bid_str] = line |> String.split(" ")
    %CamelCards{cards: String.graphemes(hand_str), bid: String.to_integer(bid_str)}
  end

  def solve(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&CamelCards.parse/1)
    |> Enum.sort({:asc, CamelCards})
    |> Enum.with_index()
    |> Enum.map(fn {%CamelCards{bid: b}, i} -> b * (i + 1) end)
    |> Enum.sum()
  end
end

# Part 2: update the score_hand fn
defmodule CamelCards2 do
  defstruct [:cards, :bid]

  def card_value("A"), do: 14
  def card_value("K"), do: 13
  def card_value("Q"), do: 12
  # make J the worst card
  def card_value("J"), do: 1
  def card_value("T"), do: 10

  def card_value(n) do
    {value, ""} = Integer.parse(n)
    value
  end

  defp hand_value([5 | _]), do: 6
  defp hand_value([4 | _]), do: 5
  defp hand_value([3, 2 | _]), do: 4
  defp hand_value([3 | _]), do: 3
  defp hand_value([2, 2 | _]), do: 2
  defp hand_value([2 | _]), do: 1
  defp hand_value(_), do: 0

  def compare(a, b) do
    a_score = score_hand(a)
    b_score = score_hand(b)

    cond do
      a_score > b_score ->
        :gt

      a_score < b_score ->
        :lt

      true ->
        compare_cards(a.cards, b.cards)
    end
  end

  def score_hand(hand) do
    freqs =
      hand.cards
      |> Enum.frequencies()

    # discard all the Js
    {j_count, card_map} = Map.pop(freqs, "J")

    card_map
    # put a J with count 0 to handle the case of 5 Js
    |> Map.put("J", 0)
    |> Map.values()
    |> Enum.sort(:desc)
    # the best way to use the joker is to increase the count of your best card
    |> List.update_at(0, &(&1 + if(j_count, do: j_count, else: 0)))
    |> hand_value()
  end

  def compare_cards([c], [d]) do
    if card_value(c) >= card_value(d), do: :gt, else: :lt
  end

  def compare_cards([c | c_rest], [d | d_rest]) do
    cond do
      card_value(c) > card_value(d) ->
        :gt

      card_value(c) < card_value(d) ->
        :lt

      true ->
        compare_cards(c_rest, d_rest)
    end
  end

  def parse(line) do
    [hand_str, bid_str] = line |> String.split(" ")
    %CamelCards2{cards: String.graphemes(hand_str), bid: String.to_integer(bid_str)}
  end

  def solve(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&CamelCards2.parse/1)
    |> Enum.sort({:asc, CamelCards2})
    |> Enum.with_index()
    |> Enum.map(fn {%CamelCards2{bid: b}, i} -> b * (i + 1) end)
    |> Enum.sum()
  end
end
