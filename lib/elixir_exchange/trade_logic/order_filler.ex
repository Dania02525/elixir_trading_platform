defmodule ElixirExchange.OrderFiller do

  def fill_order(new, orders) do
    do_fill_order(new, orders, [])
  end

  defp do_fill_order(new, [], new_orders) do
    [new, Enum.reverse(new_orders)]
  end

  defp do_fill_order(%{unfilled_quantity: 0} = new, [order | orders], new_orders) do
    do_fill_order(new, orders, [order | new_orders])
  end

  defp do_fill_order(new, [order | orders], new_orders) do
    [new, order] = match_order(new, order)

    do_fill_order(new, orders, [order | new_orders])
  end

  defp match_order(new, order) do
    case new.type do
      "market" -> do_match_order(new, order)
      "limit" -> match_limit_order(new, order)
    end
  end

  defp match_limit_order(new, %{type: "market"} = order) do
    match_order(new, order)
  end

  defp match_limit_order(%{side: "sell"} = new, order) do
    if new.price <= order.price do
      do_match_order(new, order)
    else
      [new, order]
    end
  end

  defp match_limit_order(%{side: "buy"} = new, order) do
    if new.price >= order.price do
      do_match_order(new, order)
    else
      [new, order]
    end
  end

  defp do_match_order(new, order) do
    conditions = [
      order.unfilled_quantity >= new.unfilled_quantity,
      order.unfilled_quantity - new.unfilled_quantity > 0
    ]

    updated_order =
      case conditions do
        [true, true] ->
          order
          |> Map.put(:unfilled_quantity, order.unfilled_quantity - new.unfilled_quantity)
          |> Map.put(:status, "partially_filled")
        [true, false] ->
          order
          |> Map.put(:unfilled_quantity, 0)
          |> Map.put(:status, "filled")
        [false, _] ->
          order
          |> Map.put(:unfilled_quantity, 0)
          |> Map.put(:status, "filled")
      end

    updated_new =
      case conditions do
        [true, _] ->
          new
          |> Map.put(:unfilled_quantity, 0)
          |> Map.put(:status, "filled")
        [false, _] ->
          new
          |> Map.put(:unfilled_quantity, new.unfilled_quantity - order.unfilled_quantity)
          |> Map.put(:status, "partially_filled")
      end

    [updated_new, updated_order]
  end
end
