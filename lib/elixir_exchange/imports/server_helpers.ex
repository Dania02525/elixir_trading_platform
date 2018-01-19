defmodule ElixirExchange.ServerHelpers do
  import ElixirExchange.FormatHelpers

  def process_alias(pair, side) do
    String.to_atom("#{side}_#{pair}")
  end

  ##
  #
  # Notifier
  #
  ##


  def notify_market(old_state, new_state) do
    market_leader =
      old_state
      |> Enum.reverse
      |> Enum.find(fn(o)->
        o.type == "limit" && (o.status == "filled" || o.status == "partially_filled")
      end)

    do_notify_market(new_state, market_leader)
  end

  def do_notify_market(state, %{side: "sell"} = market_leader) do
    payload = %{
      order_data: %{
        sells: collapse_orders(state)
      },
      market_price: market_leader.price
    }

    pair = market_leader.pair

    ElixirExchangeWeb.Endpoint.broadcast("trading:#{pair}", "update_orders", payload)
  end

  def do_notify_market(state, %{side: "buy"} = market_leader) do
    payload = %{
      order_data: %{
        buys: collapse_orders(state)
      },
      market_price: market_leader.price
    }

    pair = market_leader.pair

    ElixirExchangeWeb.Endpoint.broadcast("trading:#{pair}", "update_orders", payload)
  end

  def do_notify_market(_state, _any) do
    :noop
  end


  ##
  #
  # Order filling
  #
  ##

  def maybe_fill_order(order, []) do
    push_order(order)
    []
  end

  def maybe_fill_order(%{type: "market"} = order, state) do
    do_fill_order(order, state)
  end

  def maybe_fill_order(%{type: "limit", side: "sell"} = order, state) do
    if List.first(state).price > order.price do
      do_fill_order(order, state)
    else
      push_order(order)
      state
    end
  end

  def maybe_fill_order(%{type: "limit", side: "buy"} = order, state) do
    if List.first(state).price < order.price do
      do_fill_order(order, state)
    else
      push_order(order)
      state
    end
  end

  def do_fill_order(order, state) do
    [order, mixed_state] = ElixirExchange.OrderFiller.fill_order(order, state)

    new_state =
      Enum.reject(mixed_state, fn(o)->
        o.status == "filled" && o.unfilled_quantity == 0
      end)

    notify_market(mixed_state, new_state)
    push_order(order)

    new_state
  end

  ##
  #
  # Order Caching
  #
  ##

  def push_order(%{unfilled_quantity: 0, status: "filled"}) do
    :noop
  end

  def push_order(%{side: "buy", pair: pair} = order) do
    GenServer.cast(process_alias(pair, "buy"), {:push_order, order})
  end

  def push_order(%{side: "sell", pair: pair} = order) do
    GenServer.cast(process_alias(pair, "sell"), {:push_order, order})
  end
end
