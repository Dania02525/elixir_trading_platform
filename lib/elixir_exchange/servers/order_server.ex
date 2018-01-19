defmodule ElixirExchange.OrderServer do
  use GenServer

  import ElixirExchange.ServerHelpers

  ##
  #
  # Public Api
  #
  ##

  def buy_orders(pair) do
    GenServer.call(process_alias(pair, "buy"), :get_orders)
  end

  def sell_orders(pair) do
    GenServer.call(process_alias(pair, "sell"), :get_orders)
  end

  def fill_order(%{side: side, pair: pair} = order) do
    GenServer.call(process_alias(pair, side), {:fill_order, order})
  end

  ##
  #
  # GenServer Callbacks
  #
  ##

  def start_link(pair, side) do
    GenServer.start_link(__MODULE__, %{pair: pair, side: side}, name: process_alias(pair, side))
  end

  def init(%{pair: pair, side: side}) do
    state =
      Enum.sort_by(ElixirExchange.OrderData.query_active_orders(pair, side), fn(o)->
        [o.price, o.created]
      end)

    {:ok, state}
  end

  def handle_call(:get_orders, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:fill_order, order}, _from, state) do
    {:noreply, maybe_fill_order(order, state)}
  end

  def handle_cast({:push_order, order}, state) do
    sorted_orders =
      Enum.sort_by([ order | state], fn(o)->
        case o.type do
          "market" -> [0, 0, o.created]
          "limit" -> [1, o.price, o.created]
        end
      end)

    notify_market(sorted_orders, sorted_orders)

    {:noreply, sorted_orders}
  end
end
