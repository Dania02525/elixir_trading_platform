defmodule ElixirExchange.GraphData do
  def init(pair) do
    ElixirExchange.TradeHistoryCache.get_history(pair)
  end

  # this would be produced from the filled orders in the database,
  # and cached in the agent process
  def gen_fake_history(count) do
    do_gen_fake_history(count, [])
  end

  def gen_forward_datapoint(prev) do
    new_open = random_move(prev.open, random_sign())

    %{
      date: DateTime.utc_now(),
      open: new_open,
      high: random_move(new_open, 1),
      low: random_move(new_open, -1),
      close: random_move(new_open, random_sign() * 0.5),
      volume: 3134 + (:rand.uniform(500) * random_sign())
    }
  end

  def gen_fake_datapoint(previous) do
    prev =
      if is_nil(previous) do
         %{
          date: DateTime.utc_now(),
          open: 0.02322,
          high: 0.02442,
          low: 0.02134,
          close: 0.2300,
          volume: 3134
        }
      else
        previous
      end

    new_open = random_move(prev.open, random_sign())

    %{
      date: shift_time(prev.date, -5),
      open: new_open,
      high: random_move(new_open, 1),
      low: random_move(new_open, -1),
      close: random_move(new_open, random_sign() * 0.5),
      volume: 3134 + (:rand.uniform(500) * random_sign())
    }
  end

  defp do_gen_fake_history(0, acc) do
    acc
  end

  defp do_gen_fake_history(count, acc) do
    do_gen_fake_history(count - 1, [ gen_fake_datapoint(List.first(acc)) | acc ])
  end

  # change randomly by 10% up or down
  defp random_move(number, multiplier) do
    pct = ((:rand.uniform(10)) / 100.0) * multiplier
    number * (1 + pct)
  end

  defp random_sign do
    if :rand.uniform(2) == 2 do
      -1
    else
      1
    end
  end

  defp shift_time(date, minutes) do
    case [date.minute <= minutes, date.hour == 0, date.day == 1, date.month == 1] do
      [false, _, _, _] ->
        %{ date | minute: date.minute + minutes }
      [true, false, _, _] ->
        struct(date, %{
          minute: 59 - (minutes - date.minute),
          hour: date.hour - 1
        })
      [true, true, false, _] ->
        struct(date, %{
          minute: 59 - (minutes - date.minute),
          hour: 11,
          month: date.month - 1
        })
      [true, true, true, false] ->
        struct(date, %{
          minute: 59 - (minutes - date.minute),
          hour: 11,
          month: 12,
          year: date.year - 1
        })
    end
  end
end
