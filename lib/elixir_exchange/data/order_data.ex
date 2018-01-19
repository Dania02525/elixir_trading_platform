defmodule ElixirExchange.OrderData do
  def market_price(pair) do
    ElixirExchange.FakeOrderData.market_price()
  end

  def query_active_orders(pair, "buy") do
    ElixirExchange.FakeOrderData.fake_orders
    |> Enum.filter(fn({_k, o})->
      o.side == "buy" && (o.status == "open" || o.status == "partially_filled") && o.type == "limit"
    end)
    |> Enum.map(fn {_k, v}-> v end)
  end

  def query_active_orders(pair, "sell") do
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
end
