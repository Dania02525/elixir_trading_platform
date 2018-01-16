defmodule ElixirExchange.MarketOrderFiller do
  require Logger

  def fill_market_order(order, sell_orders) do
    sorted =
      Enum.sort_by(sell_orders, fn(o)->
        [o.price, o.created]
      end)

    [order, modified_orders] = do_fill_market_order(order, sorted, [])
    [order, modified_orders, new_market_price(modified_orders)]
  end

  # the market order was completely filled
  def do_fill_market_order(%{unfilled_quantity: 0} = order, _, modified_orders) do
    [Map.put(order, :status, "filled"), modified_orders]
  end

  # the market order could not be completely filled ????
  def do_fill_market_order(order,  [], modified_orders) do
    if order.quantity != order.unfilled_quantity do
      [Map.put(order, :status, "partially_filled"), modified_orders]
    else
      [order, modified_orders]
    end
  end

  def do_fill_market_order(order, [sell | sells], modified_orders) do
    if sell.unfilled_quantity >= order.unfilled_quantity do
      filled_sell =
        if sell.unfilled_quantity - order.unfilled_quantity > 0 do
          sell
          |> Map.put(:unfilled_quantity, sell.unfilled_quantity - order.unfilled_quantity)
          |> Map.put(:status, "partially_filled")
        else
          sell
          |> Map.put(:unfilled_quantity, 0)
          |> Map.put(:status, "filled")
        end

      filled_order =
        order
        |> Map.put(:unfilled_quantity, 0)
        |> Map.put(:status, "filled")

      do_fill_market_order(filled_order, sells, [filled_sell | modified_orders])
    else
      filled_sell =
        sell
        |> Map.put(:unfilled_quantity, 0)
        |> Map.put(:status, "filled")

      filled_order =
        order
        |> Map.put(:unfilled_quantity, order.unfilled_quantity - sell.unfilled_quantity)
        |> Map.put(:status, "partially_filled")

      do_fill_market_order(filled_order, sells, [filled_sell | modified_orders])
    end
  end

  defp new_market_price(filled_sell_orders) do
    Map.get(List.first(filled_sell_orders), :price)
  end
end
