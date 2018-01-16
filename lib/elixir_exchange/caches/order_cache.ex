defmodule ElixirExchange.OrderCache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_) do
    :ets.new(:order_cache, [:set, :public, :named_table])
    init_cache()
    {:ok, []}
  end

  def update_modified_sell_orders(pair, orders) do
    ids = Enum.map(orders, fn(o)-> o.id end)
    sells =
      sell_orders(pair)
      |> Enum.reject(fn(o)->
        Enum.member?(ids, o.id)
      end)

    modified_sells =
      orders
      |> Enum.filter(fn(o)->
        o.status == "open" || o.status == "partially_filled"
      end)

    :ets.insert(:graph_cache, {{pair, "sell"}, modified_sells ++ sells})
  end

  def buy_orders(pair) do
    {_key, buys} = List.first(:ets.lookup(:graph_cache, {pair, "buy"}))
    buys
  end

  def sell_orders(pair) do
    {_key, sells} = List.first(:ets.lookup(:graph_cache, {pair, "sell"}))
    sells
  end

  def init_cache do
    Application.fetch_env!(:elixir_exchange, :pairs)
    |> Enum.each(fn(pair)->
      buys = ElixirExchange.OrderData.query_active_buy_orders(pair)
      sells = ElixirExchange.OrderData.query_active_sell_orders(pair)
      :ets.insert(:graph_cache, {{pair, "buy"}, buys})
      :ets.insert(:graph_cache, {{pair, "sell"}, sells})
    end)
  end
end
