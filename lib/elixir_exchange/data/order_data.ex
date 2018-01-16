defmodule ElixirExchange.OrderData do
  def market_price(pair) do
    ElixirExchange.FakeOrderData.market_price()
  end

  def query_active_buy_orders(pair) do
    ElixirExchange.FakeOrderData.fake_orders
    |> Enum.filter(fn({_k, o})->
      o.side == "buy" && (o.status == "open" || o.status == "partially_filled") && o.type == "limit"
    end)
    |> Enum.map(fn {_k, v}-> v end)
  end

  def query_active_sell_orders(pair) do
    ElixirExchange.FakeOrderData.fake_orders
    |> Enum.filter(fn({_k, o})->
      o.side == "sell" && (o.status == "open" || o.status == "partially_filled") && o.type == "limit"
    end)
    |> Enum.map(fn {_k, v}-> v end)
  end

  def orders_by_user(pair, user_id) do
    ElixirExchange.FakeOrderData.fake_orders
    |> Enum.filter(fn({_k, o})->
      o.user_id == user_id
    end)
    |> Enum.map(fn {_k, v}-> v end)
  end

  def cached_buy_orders(pair) do
    ElixirExchange.OrderCache.buy_orders(pair)
  end

  def cached_sell_orders(pair) do
    ElixirExchange.OrderCache.sell_orders(pair)
  end

  # order filling logic
  def fill_market_order(order) do
    sell_orders = cached_sell_orders(order.pair)
    [order, modified_orders, new_market_price] =
      ElixirExchange.MarketOrderFiller.fill_market_order(order, sell_orders)

    ElixirExchange.OrderCache.update_modified_sell_orders(order.pair, modified_orders)

    # asyncronously balance limit orders

    broadcast_new_order_data(order.pair, new_market_price)
  end

  def balance_limit_orders do
    # not impl
  end

  def broadcast_new_order_data(pair, price) do
    data = %{
      order_data: %{
        buys: collapse_orders(cached_buy_orders(pair)),
        sells: collapse_orders(cached_sell_orders(pair))
      },
      market_price: price
    }

    ElixirExchangeWeb.Endpoint.broadcast("trading:#{pair}", "update_orders", data)
  end

  defp collapse_orders(orders) do
    Enum.reduce(orders, %{}, fn(o, acc)->
      existing = Map.get(acc, o.price)
      if existing do
        order = %{
          price: o.price,
          quantity: existing.quantity + o.unfilled_quantity
        }
        Map.put(acc, o.price, order)
      else
        order = %{
            price: o.price,
            quantity: o.unfilled_quantity
          }
        Map.put(acc, o.price, order)
      end
    end)
    |> Enum.map(fn {_k, v}->
      v
    end)
  end
end
